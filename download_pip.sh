#!/bin/bash

# Début du script
echo "--- Script de téléchargement de paquets Python avec PIP ---"
echo ""
echo "--- Definition de l'environnement:"
# Display des versions de python par défaut
echo "Python par défault: $(which python), $(python -V)"

# Si l'installation se fait pour une version d'ANACONDA
read -p "> Installation pour ANACONDA ? (y/n) " anaconda
if [ "$anaconda" == "y" ]
then
    echo ">> Modification de l'environnement pour ANACONDA ---"
    read -p "Version d'Anaconda utilisée (par ex: 2024.06)" anacondaVer
    
    pythonPath="/home/codes/ANACONDA3/$anacondaVer/bin"
    if [ -d $pythonPath ]
    then
        export PATH=$pythonPath:$PATH && echo "PATH modifié"
        echo "Environnement utilisé: $(which python), $(python -V)"
        pythonVer=$(python -V | cut -d" " -f2)
        echo "<<"
        echo ""
    else
        echo "Le dossier $pythonPath n'existe pas"
        echo "--- Fermeture du script"
        exit
    fi
else
    # Si pas de version d'ANACONDA utilisée, 
    echo ""
    read -p "Version de python utilisée: " pythonVer
fi
read -p "Paquet à installer: " package
read -p "Version du paquet à installer: (appuyer sur Entrée pour télécharger la dernière version disponible)" packageVer

pathDownload=$package$packageVer-python$pythonVer

echo "Téléchargement de $package et des dépendances"
echo "Les paquets sont dans le dossier: $pathDownload"

mkdir $pathDownload
cd $pathDownload

if [ "$packageVer" == "" ]
then
    echo "Version: Dernière version compatible"
    pip download --python-version $pythonVer --only-binary=:all: $package 
else
    echo "Version: $pythonVer"
    pip download --python-version $pythonVer --only-binary=:all: $package==$packageVer
fi


echo "Création de $pathDownload-requirements.txt"
ls | cut -d"-" -f1,2 | sed "s/-/==/" > ../$pathDownload-requirements.txt
chmod 777 ../$pathDownload-requirements.txt

#if [ "$anaconda" == "y" ]
#then
echo "Création de $pathDownload-installed.txt"
pip freeze > ../$pathDownload-installed.txt

echo "Création de $pathDownload-dependencies.txt"
cat ../$pathDownload-requirements.txt | while read line
do
    rm -rf ../$pathDownload-dependencies.txt
    if [ ! "$(cat ../$pathDownload-installed.txt | grep $line)" == "" ]
    then
        echo $line >> ../$pathDownload-dependencies.txt
    fi
done

read -p "Supprimer les paquets dont la dépendance est déjà résolue ? (y/n) " supprDep
if [ "$supprDep" == "y" ]
then
    cat ../$pathDownload-dependencies.txt | sed "s/==/-/" | while read line
    do
        echo "Suppression de $line*" && rm -f $line* 
    done

fi
#fi

cd ../
echo "Compression du dossier $pathDownload"
tar cvf $pathDownload.tar.gz $pathDownload
echo "Suppression du dossier $pathDownload"
rm -rf $pathDownload

echo "--- Fin du script ---"