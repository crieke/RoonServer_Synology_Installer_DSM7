#!/bin/bash
currentDir="$(dirname "$0")"
wizardFile="$(date +%s)_wizard.php"

/bin/cat > /tmp/$wizardFile <<EOF
<?php

\$STEP1 = array(
    "step_title" => "Where should your database be stored?",
    "items" => [array(
        "type" => "combobox",
        "desc" => "Please specify, on which shared folder Roon Server should store its database files and on which shared folder your Music media files are stored.<br>",
        "invalid_next_disabled_v2" => TRUE,
        "subitems" => [array(
            "key" => "WIZARD_DATABASE_DIR",
            "desc" => "🗃️ - Roon Server's database",
            "displayField" => "name",
            "defaultValue" => "Please select",
            "valueField" => "name",
            "forceSelection" => TRUE,
            "title" => "Roon Server database",
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
                "fn" => "{var dbshare=arguments[0];var d=dbshare != \"homes\" && dbshare != \"home\" && dbshare != \"Please select\"; if (!d) return 'Please choose a different shared folder for your database.';return true;}"
            )
        ),
          array(
            "key" => "WIZARD_MUSIC_DIR",
            "desc" => "🎵 - Music Directory",
            "displayField" => "name",
            "defaultValue" => "Please select",
            "valueField" => "name",
            "forceSelection" => TRUE,
            "title" => "Location of Music media files",
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
                "fn" => "{var dbshare=arguments[0];var d=dbshare != \"homes\" && dbshare != \"home\" && dbshare != \"Please select\"; if (!d) return 'Please choose a different shared folder for your database.';return true;}"
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
    "step_title" => "Retrieve Roon Server automatically from the Internet?",
    "items" => [array(
        "type" => "singleselect",
        "desc" => "In case your diskstation has issues downloading the Roon Server application from Roon Labs, the installer can check your specified database shared folder for the required file (\"RoonServer_linuxx64.tar.bz2\") and install Roon Server offline.<br>",
        "invalid_next_disabled_v2" => true,
        "subitems" => [array(
            "key" => "ONLINEINSTALL",
            "desc" => "Online installation (recommended!)",
            "defaultValue" => TRUE
          ),
          array(
            "key" => "OFFLINEINSTALL",
            "desc" => "Offline installation",
            "defaultValue" => false
          )]
    ), array( 
        "type" => "multiselect",
        "desc" => "",
        "subitems" => [array(
           "key" => "WIZARD_DEBUG",
           "hidden" => false,
           "desc" => "Create Installation Log?",
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
