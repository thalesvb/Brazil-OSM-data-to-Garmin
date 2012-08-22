#!/bin/bash
#
# Gerador de mapas do Brasil para dispositivos GPS Garmin
# Versão 0.4
# Autor: Rodrigo de Avila, com contribuição dos membros da lista talk-br
# http://lists.openstreetmap.org/listinfo/talk-br
# mailto:rodrigo@avila.net.br
# http://maps.avila.net.br/garmin
# http://www.avila.net.br
#
# Script de domínio público. Nenhum direito reservado.
#
# Para instalar:
#	- Depende de:
#               * curl (ou wget)
#		* nsis
#		* mkgmap
#		* osmosis
#		* splitter
#
# [rodrigo @ 23/04/2012] Alterada saída de erros dos scripts para logs em arquivo.
#                        Troca do download via wget para download via curl.
#
# [rodrigo @ 17/05/2011] Removida chamada para upload e atualização do site. Vou fazer isso manualmente.
#
# [rodrigo @ 18/03/2011] Adicionado teste de tamanho do arquivo baixado. Se for menor que um determinado valor,
#                        ele não é processado, e aguarda 1 hora para tentar de novo.
#
# [rodrigo @ 24/01/2011] Atualizado para usar arquivo binário brazil.osm.pbf
#
# [rodrigo @ 29/06/2010] Atualizado para gerar arquivo executável do mapsource, bem como verificar se o upload
#                        dos arquivos para o Dropbox já terminou. Enquanto não termina, não notifica o site.
#
# [rodrigo @ 15/06/2010] Primeiro import dos scripts para o github.
#
# [rodrigo @ 15/04/2010] Atualizado para fazer xml apenas de highways secundárias ou superiores. Será usado em
#                        programa de roteamento.
#
# [rodrigo @ 01/02/2010] Atualizado para usar download do arquivo do Brasil, agora disponível no geofabrik.

function processadownload() {

  echo "Dividindo arquivo osm do Brasil . . ."
  java -Xmx2000m -jar ${SPLITTER_DIR}/splitter.jar --output=xml ${SA} 1> /dev/null 2> splitter.log

  echo "Compilando mapas . . ."
  rm ./img/*.img 2> /dev/null
  rm ./img/*.exe 2> /dev/null

  for FILE in `ls 632*.osm.gz`;
    do
      eval NOME="\${FILE%${FILE#????????}}"
       echo "   ===> Processando arquivo ${NOME}"
      java -jar ${MKGMAP_DIR}/mkgmap.jar --read-config=${ORIGINAL_DIR}/configs/${CONFIG_NAME}-map.cfg -n ${NOME} ${FILE} 1> /dev/null 2> mkgmap-${NOME}.log
  done

# Parametro --nsis se for criar instalador
  echo "Compilando gmapsupp.img . . ."
  java -jar ${MKGMAP_DIR}/mkgmap.jar --read-config=${ORIGINAL_DIR}/configs/${CONFIG_NAME}-gmapsupp.cfg `ls 632*.img` 1> /dev/null 2> mkgmap-gmapsupp.log

#  echo "Compilando NSIS file . . ."
#  makensis mapsource.nsi 1> /dev/null 2> makensis.log

  mv gmapsupp.img ${ORIGINAL_DIR}/img/
#  mv Mapas\ do\ Brasil\ -\ maps.avila.net.br.exe ./img/

  rm template.args 2> /dev/null
  rm areas.list 2> /dev/null
  rm *.img 2> /dev/null
  rm *.tdb 2> /dev/null
  rm osmmap.* 2> /dev/null

  echo "Comprimindo arquivo para distribuição . . ."
  cd ${ORIGINAL_DIR}/img
  zip brazil-${DATAZIP}.zip gmapsupp.img > /dev/null
#  zip brazil-mapsource-${DATAZIP}.zip Mapas\ do\ Brasil\ -\ maps.avila.net.br.exe > /dev/null

  sha512sum brazil-${DATAZIP}.zip > brazil-${DATAZIP}.zip.sha512
#  sha512sum brazil-mapsource-${DATAZIP}.zip > brazil-mapsource-${DATAZIP}.zip.sha512

  echo ""
  echo "Arquivos criados com sucesso. Rode o rsync para envia-los ao SourceForge."
  echo ""
}

# clear

# Config a ser utilizada
CONFIG_NAME=Symbian
# Diretório temporário, para não poluir o 'workspace' do código com os arquivos
TEMP_DIR=$(mktemp -d --tmpdir osm-garmin.XXX)

# Diretório atual, para escrever os arquivos de saída
ORIGINAL_DIR=$(pwd)

# Diretório do OSMOSIS
OSMOSIS_DIR="/home/thales/OSM/tools/osmosis-0.40.1"

# Diretório do Splitter
SPLITTER_DIR="/home/thales/OSM/tools/splitter-r200"

# Diretório do MkgMap
MKGMAP_DIR="/home/thales/OSM/tools/mkgmap"

# Arquivo com dados do Brasil
SA="brazil.osm.pbf"

# Tamanho mínimo (em bytes) do arquivo (para saber se baixou o arquivo completo)
TAMANHO_MINIMO_ARQUIVO="65000000"

# Local de download do arquivo
DOWNLOAD="http://download.geofabrik.de/osm/south-america/"

# Data atual, para ser usado no nome do arquivo zip
DATAZIP=`date +%Y%m%d`

echo "Movendo para o diretório temporário para realizar as operações . . ."
cd ${TEMP_DIR}

echo "Baixando dados do Brasil (arquivo ${SA}) . . ."
#curl -o ${SA} "${DOWNLOAD}${SA}"
wget -c ${DOWNLOAD}${SA}
# O cp serve apenas para 'debugar', inves de ter q fazer download toda vez
# cp /home/thales/OSM/${SA} ${TEMP_DIR}/

# Testa se o arquivo baixado é maior que o tamanho do parâmetro
TAMANHO_ARQUIVO=$(stat -c%s "${SA}")

echo "Tamanho do arquivo: ${TAMANHO_ARQUIVO}"
echo "Tamanho Mínimo    : ${TAMANHO_MINIMO_ARQUIVO}"

if [ ${TAMANHO_ARQUIVO} -gt ${TAMANHO_MINIMO_ARQUIVO} ] ;
  then
    processadownload
  else
    echo "Fail"
fi

echo "Removendo arquivos temporários e voltando ao ponto de origem . . ."
cd $ORIGINAL_DIR
rm -r $TEMP_DIR
