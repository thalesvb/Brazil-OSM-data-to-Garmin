!define DEFAULT_DIR "C:\Garmin\Maps\Brasil OSM"
!define INSTALLER_DESCRIPTION "Mapas do Brasil - maps.avila.net.br"
!define INSTALLER_NAME "Mapas do Brasil - maps.avila.net.br"
!define MAPNAME "osmmap"
!define PRODUCT_ID "3"
!define REG_KEY "Brasil OSM"

SetCompressor /SOLID lzma

; Includes
!include "MUI2.nsh"

; Installer pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE license.txt
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!define MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "PortugueseBR"

Name "${INSTALLER_DESCRIPTION}"
OutFile "${INSTALLER_NAME}.exe"
InstallDir "${DEFAULT_DIR}"

Section "MainSection" SectionMain
  SetOutPath "$INSTDIR"
  File "${MAPNAME}.img"
  File "${MAPNAME}.tdb"
  File "63240001.img"
  File "63240002.img"
  File "63240003.img"
  File "63240004.img"

  WriteRegBin HKLM "SOFTWARE\Garmin\MapSource\Families\${REG_KEY}" "ID" 0000
  WriteRegStr HKLM "SOFTWARE\Garmin\MapSource\Families\${REG_KEY}\${PRODUCT_ID}" "BMAP" "$INSTDIR\${MAPNAME}.img"
  WriteRegStr HKLM "SOFTWARE\Garmin\MapSource\Families\${REG_KEY}\${PRODUCT_ID}" "LOC" "$INSTDIR"
  WriteRegStr HKLM "SOFTWARE\Garmin\MapSource\Families\${REG_KEY}\${PRODUCT_ID}" "TDB" "$INSTDIR\${MAPNAME}.tdb"

  WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd

Section "Uninstall"
  Delete "$INSTDIR\${MAPNAME}.img"
  Delete "$INSTDIR\${MAPNAME}.tdb"
  Delete "$INSTDIR\63240001.img"
  Delete "$INSTDIR\63240002.img"
  Delete "$INSTDIR\63240003.img"
  Delete "$INSTDIR\63240004.img"
  Delete "$INSTDIR\Uninstall.exe"

  RmDir "$INSTDIR"

  DeleteRegValue HKLM "SOFTWARE\Garmin\MapSource\Families\${REG_KEY}" "ID"
  DeleteRegValue HKLM "SOFTWARE\Garmin\MapSource\Families\${REG_KEY}\${PRODUCT_ID}" "BMAP"
  DeleteRegValue HKLM "SOFTWARE\Garmin\MapSource\Families\${REG_KEY}\${PRODUCT_ID}" "LOC"
  DeleteRegValue HKLM "SOFTWARE\Garmin\MapSource\Families\${REG_KEY}\${PRODUCT_ID}" "TDB"
  DeleteRegKey /IfEmpty HKLM "SOFTWARE\Garmin\MapSource\Families\${REG_KEY}\${PRODUCT_ID}"
  DeleteRegKey /IfEmpty HKLM "SOFTWARE\Garmin\MapSource\Families\${REG_KEY}"

SectionEnd
