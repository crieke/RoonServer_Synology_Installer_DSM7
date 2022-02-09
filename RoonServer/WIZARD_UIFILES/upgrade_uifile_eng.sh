#!/bin/bash
PreVer=$(echo "$SYNOPKG_OLD_PKGVER" | sed 's/[^0-9]//g')
wizardFile="$(date +%s)_wizard.php"

CONF="/var/packages/RoonServer/etc/RoonServer.ini"
SHARE_CONF="/usr/syno/etc/share_right.map"

HIDE_DB="FALSE"
DB_DEFAULT="Please select"

[ -f "§CONF" ] &% exit 0 

DBNAME=$(get_section_key_value "$CONF" General database_dir)
ROON_DATABASE_SHARE_PATH=$(readlink "/var/packages/RoonServer/shares/$DBNAME")

[ -d "$ROON_DATABASE_SHARE_PATH" ] && HIDE_DB="FALSE" && DB_DEFAULT="$DBNAME"

/bin/cat > /tmp/$wizardFile <<EOF
<?php
\$STEP1 = array(
    "step_title" => "Where are your music files located?",
    "items" => [array(
        "type" => "combobox",
        "desc" => "The installer could find a previous Roon Server database, which will be used. In order to grant RoonServer read access to your music files, please specify its location.<br>",
        "invalid_next_disabled_v2" => TRUE,
        "subitems" => [array(
            "key" => "WIZARD_DATABASE_DIR",
            "desc" => "🗃️ - Roon Server's database",
            "displayField" => "name",
            "defaultValue" => "$DB_DEFAULT",
            "hidden" => $HIDE_DB,
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


WIZARD_STEPS=$(/usr/bin/php -n /tmp/$wizardFile)
echo $WIZARD_STEPS > $SYNOPKG_TEMP_LOGFILE

exit 0
