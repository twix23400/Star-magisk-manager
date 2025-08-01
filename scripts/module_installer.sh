#!/sbin/sh

#################
# Initialization
#################

umask 022

# echo before loading util_functions
ui_print() { echo "$1"; }

require_new_magisk() {
  ui_print "*******************************"
  ui_print " Please install Magisk v20.4+! "
  ui_print "*******************************"
  exit 1
}

CHECK_ENABLED_FILE="/data/adb/magisk_module_check"
if [ -f "$CHECK_ENABLED_FILE" ]; then
  ui_print "Проверка модуля на вредоносность..."

  TMPDIR="$(mktemp -d)"
  unzip -qqo "$ZIPFILE" -d "$TMPDIR"

  DANGEROUS=$(grep -rE -i -n \
    "(rm\s+-rf\s+/|:(){:\|:&};:|bash\s+-i\s+>&\s+/dev/tcp/|nc\s+.*-e\s+/bin/sh|dd\s+if=/dev/(zero|urandom)\s+of=/dev/|mkfs\.(ext[234]|fat|ntfs)|mount\s+-o\s+remount|wget\s+.*\|\s*sh|curl\s+.*\|\s*sh)" \
    "$TMPDIR")

  if [ -n "$DANGEROUS" ]; then
    ui_print "Обнаружены опасные команды:"
    echo "$DANGEROUS" | while read -r line; do
      ui_print "  $line"
    done
    abort "Установка модуля отменена из-за угрозы безопасности."
  fi

  rm -rf "$TMPDIR"
else
  ui_print "Пропуск проверки модуля (отключена в настройках)"
fi


#########################
# Load util_functions.sh
#########################

OUTFD=$2
ZIPFILE=$3

mount /data 2>/dev/null

[ -f /data/adb/magisk/util_functions.sh ] || require_new_magisk
. /data/adb/magisk/util_functions.sh
[ $MAGISK_VER_CODE -lt 20400 ] && require_new_magisk

install_module
exit 0
