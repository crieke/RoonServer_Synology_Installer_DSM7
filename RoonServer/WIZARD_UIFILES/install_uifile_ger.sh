#!/bin/bash
currentDir="$(dirname "$0")"
wizardFile="$(date +%s)_wizard.php"

/bin/cat > /tmp/$wizardFile <<EOF
<?php

\$STEP1 = array(
    "step_title" => "Speicherorte feslegen",
    "items" => [array(
        "type" => "combobox",
        "desc" => "In welchem Ordner soll Roon Servers Datenbank abgelegt werden und in welchem Ordner befinden sich deine Musikdateien?<br>Roon Server erhält während der Installation die erforderlichen Zugriffsrechte.<br>",
        "invalid_next_disabled_v2" => TRUE,
        "subitems" => [array(
            "key" => "WIZARD_DATABASE_DIR",
            "desc" => "🗃️ - Speicherort Datenbank",
            "displayField" => "name",
            "defaultValue" => "Bitte wählen",
            "valueField" => "name",
            "forceSelection" => TRUE,
            "title" => "Datenbank Verzeichnis",
            "editable" => FALSE,
            "api_store" => array(
                "api" => "SYNO.FileStation.List",
                "method" => "list_share",
                "version" => 2,
                "root" => "shares",
                "idProperty" => "name",
                "fields" => ["name"]
            ),
            "validator" => array(
                "fn" => "{var dbshare=arguments[0];var d=dbshare != \"homes\" && dbshare != \"home\" && dbshare != \"Bitte wählen\"; if (!d) return 'Please choose a different shared folder for your database.';return true;}"
            )
        ),
          array(
            "key" => "WIZARD_MUSIC_DIR",
            "desc" => "🎵 - Musikdateien",
            "displayField" => "name",
            "defaultValue" => "Bitte wählen",
            "valueField" => "name",
            "forceSelection" => TRUE,
            "title" => "Ort deiner Musikdateien",
            "editable" => FALSE,
            "api_store" => array(
                "api" => "SYNO.FileStation.List",
                "method" => "list_share",
                "version" => 2,
                "root" => "shares",
                "idProperty" => "name",
                "fields" => ["name"]
            ),
            "validator" => array(
                "fn" => "{var dbshare=arguments[0];var d=dbshare != \"homes\" && dbshare != \"home\" && dbshare != \"Bitte wählen\"; if (!d) return 'Please choose a different shared folder for your database.';return true;}"
            )
        ),
          array(
            "key" => "WIZARD_HIDDEN_FIELD",
            "desc" => "This is a placeholder field. It is a workaround, as it seems the last combobox in the PKG-WIZARD always gets filled with the first entry.",
            "displayField" => "name",
            "defaultValue"=> "Nothing to select here.",
            "valueField" => "name",
            "autoSelect" => false,
            "forceSelection" => true,
            "title" => "PLACEHOLDER",
            "editable" => false,
            "hidden" => true,
            "api_store" => array(
                "api" => "SYNO.FileStation.List",
                "method" => "list_share",
                "version" => 2,
                "root" => "shares",
                "idProperty" => "name",
                "fields" => ["name"]
            )
        )]
    )]
);
\$STEP2 = array(
    "step_title" => "Installationsdaten über das Internet laden?",
    "items" => [array(
        "type" => "singleselect",
        "desc" => "Falls deine Diskstation Probleme beim Download der Roon Server Software von der Roon Labs Webseite hat, kann die benötigte Datei (\"RoonServer_linuxx64.tar.bz2\") auch manuell in den festgelegten Datenbank Speicherort kopiert werden, um die Installation offline durchzuführen.<br>",
        "invalid_next_disabled_v2" => true,
        "subitems" => [array(
            "key" => "ONLINEINSTALL",
            "desc" => "Online-Installation (empfohlen!)",
            "defaultValue" => TRUE
          ),
          array(
            "key" => "OFFLINEINSTALL",
            "desc" => "Offline-Installation",
            "defaultValue" => false
          )]
    ), array( 
        "type" => "multiselect",
        "desc" => "",
        "subitems" => [array(
           "key" => "WIZARD_DEBUG",
           "hidden" => false,
           "desc" => "Installations log erstellen?",
           "defaultValue" => false   
        )]
    )]
);

\$WIZARD = [];
if ( !file_exists("/var/packages/RoonServer/etc/RoonServer.ini") ) {
    # Storage location already set.
    array_push(\$WIZARD, \$STEP1);
}
array_push(\$WIZARD, \$STEP2);

echo json_encode(\$WIZARD);
?>
EOF

WIZARD_STEPS=$(/usr/bin/php -n /tmp/$wizardFile)
if [ ${#WIZARD_STEPS} -gt 5 ]; then
    echo $WIZARD_STEPS > $SYNOPKG_TEMP_LOGFILE
fi
## remove temp php file
rm /tmp/$wizardFile
exit 0
