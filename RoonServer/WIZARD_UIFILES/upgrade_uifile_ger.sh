#!/bin/bash
PreVer=$(echo "$SYNOPKG_OLD_PKGVER" | sed 's/[^0-9]//g')
wizardFile="$(date +%s)_wizard.php"
/bin/cat > /tmp/$wizardFile <<EOF
<?php

\$conf_file = "/var/packages/RoonServer/etc/RoonServer.ini";
if ( file_exists(\$conf_file) ) {
  \$RoonServer_conf = parse_ini_file(\$conf_file);
  \$value_dbPath = \$RoonServer_conf['database_dir'];
  \$value_hide_dbPath = "TRUE";
} else {
  \$value_dbPath = "RoonServer";
  \$value_hide_dbPath = "TRUE" ;
}


\$STEP1 = array(
    "step_title" => "Wo liegen deine Musikdateien?",
    "items" => [array(
        "type" => "combobox",
        "desc" => "Deine RoonServer Datenbank konnte automatisch identifiziert werden. In welchem Freigabeordner befinden sich deine Musikdateien?<br>Roon Server erhält während der Installation Leserechte, damit du in Roon auf sie zugreifen kannst.<br>",
        "invalid_next_disabled_v2" => TRUE,
        "subitems" => [array(
            "key" => "WIZARD_DATABASE_DIR",
            "desc" => "🗃️ - Speicherort Datenbank",
            "displayField" => "name",
            "defaultValue" => "RoonServer",
            "hidden" => TRUE,
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

\$WIZARD = [];
array_push(\$WIZARD, \$STEP1);

echo json_encode(\$WIZARD);
?>
EOF


if [ $PreVer -le 20210308 ]; then
    WIZARD_STEPS=$(/usr/bin/php -n /tmp/$wizardFile)
    echo $WIZARD_STEPS > $SYNOPKG_TEMP_LOGFILE
  rm /tmp/$wizardFile
fi
exit 0
