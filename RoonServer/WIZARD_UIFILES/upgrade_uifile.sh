#!/bin/bash
PreVer=$(echo "$SYNOPKG_OLD_PKGVER" | sed 's/[^0-9]//g')

/bin/cat > /tmp/wizard.php <<EOF
<?php

\$conf_file = "/var/packages/RoonServer/etc/RoonServer.ini";
if ( file_exists(\$conf_file) ) {
  \$RoonServer_conf = parse_ini_file(\$conf_file);
  \$value_dbPath = \$RoonServer_conf['database_dir'];
  \$value_hide_dbPath = "TRUE";
} else {
  \$value_dbPath = "RoonServer";
  \$value_hide_dbPath = "FALSE" ;
}


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
            "defaultValue" => \$value_dbPath,
            "hidden" => \$value_hide_dbPath,
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

\$WIZARD = [];
array_push(\$WIZARD, \$STEP1);

echo json_encode(\$WIZARD);
?>
EOF


if [ $PreVer -le 20210308 ]; then
    WIZARD_STEPS=$(/usr/bin/php -n /tmp/wizard.php)
    echo $WIZARD_STEPS > $SYNOPKG_TEMP_LOGFILE
  rm /tmp/wizard.php
fi
exit 0
