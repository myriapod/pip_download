#!/bin/bash

echo "--- Script de téléchargement de paquets Python avec PIP ---"
echo ""
echo "--- Definition de l'environnement:"
echo "Python par défault: $(which python), $(python -V)"

read -p "> Modification de l'environnement ? (y/n)" modifEnv
if [[ "$modifEnv" == "y" ]]
then
    echo ">> Modification de l'environnement ---"
    read -p "Chemin vers la version de python à utiliser: " pythonPath
    export PATH=$pythonPath:$PATH && echo "PATH modifié"
    echo "Environnement utilisé: $(which python), $(python -V)"
    pythonVer=$(python -V | cut -d" " -f2)
    echo "<<"
    echo ""
else
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

if [[ "$packageVer" == "" ]]
then
    echo "Version: Dernière version compatible"
    pip download --python-version $pythonVer --only-binary=:all: $package 
else
    echo "Version: $pythonVer"
    pip download --python-version $pythonVer --only-binary=:all: $package==$packageVer
fi


echo "Création de requirements.txt"
ls | cut -d"-" -f1,2 | sed "s/-/=/" >> requirements.txt
chmod 777 requirements.txt
