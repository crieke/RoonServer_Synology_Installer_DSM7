#!/bin/bash
wizardFile="$(date +%s)_wizard.php"

# Set config path. Revert to home etc dir if ini is not in target etc
CONF="/var/packages/RoonServer/etc/RoonServer.ini"

# Hide wizard if RoonServer.ini exists and has a valid share entry
if [ -f "$CONF" ]; then
  DBNAME=$(get_section_key_value "$CONF" General database_dir)
  ROON_DATABASE_SHARE_PATH=$(readlink "/var/packages/RoonServer/shares/$DBNAME")
 [ -d "$ROON_DATABASE_SHARE_PATH" ] && exit 0
fi 

# Default Wizard Variables
HIDE_DB="FALSE"
DB_DEFAULT="Please select"
DB_DESC_TEXT=="Die Aktualisierung konnte deine Freigabe für die Roon Server Datenbank nicht lokalisieren. Bitte lege sie erneut fest."

# check for dsm6 versions without ini file.
PreVer=$(echo "$SYNOPKG_OLD_PKGVER" | sed 's/[^0-9]//g')
SHARE_CONF="/usr/syno/etc/share_right.map"

## Check if previous Version is a DSM6 install and check its fixed RoonServer shared folder path
## Hide database selection if path could be located
if [ $PreVer -le 20210308 ]; then
  dsm6Path=$(get_section_key_value "$SHARE_CONF" RoonServer path || get_section_key_value "$SHARE_CONF" RoonServer guid )
  [ -z $dsm6Path ] && DB_DEFAULT="RoonServer" && HIDE_DB="TRUE" && DB_DESC_TEXT="Deine RoonServer Datenbank konnte automatisch identifiziert werden."
fi

## Create php file to write json file
/bin/cat > /tmp/$wizardFile <<EOF
<?php
\$STEP1 = array(
    "step_title" => "Wo liegen deine Musikdateien?",
    "items" => [array(
        "type" => "combobox",
        "desc" => "$DB_DESC_TEXT Wähle noch deinen Freigabeordner, auf dem sich deine deine Musikdateien befinden.<br>Roon Server erhält dadurch Leserechte, sodass Roon auf sie zugreifen kann.<br>",
        "invalid_next_disabled_v2" => TRUE,
        "subitems" => [array(
            "key" => "WIZARD_DATABASE_DIR",
            "desc" => "🗃️ - Speicherort Datenbank",
            "displayField" => "name",
            "defaultValue" => "$DB_DEFAULT",
            "hidden" => $HIDE_DB,
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


WIZARD_STEPS=$(/usr/bin/php -n /tmp/$wizardFile)
echo $WIZARD_STEPS > $SYNOPKG_TEMP_LOGFILE
rm /tmp/$wizardFile

exit 0
