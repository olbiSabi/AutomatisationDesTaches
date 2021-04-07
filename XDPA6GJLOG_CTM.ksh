#!/bin/ksh

#------------------------------------ DESCRIPTION- ----------------------------------#
# @(#)         Script shell qui sera appelé par un shell principale. 
# @(#) ce script recupere toutes les logs de CONTROL M dans le repertoir logctm:
# @(#) /dz-pareo-ga/applis/pa6/logctm. les fichiers log recupere seront traités
# @(#) et les données important extraite.
#---------------------------------- AUTEUR ET DATE ----------------------------------#
# @(#) Auteur: Sabi ONIANKITAN
# @(#) Date Creation:
#------------------------------------ HISTORIQUE ------------------------------------#
# @(#)|    VERSION   |      NOM     |  PRENOM   |  DATE DE MISE A JOUR  |
#     |     V0.1     |  ONIANKITAN  |   SABI    |  29/03/2021           | 
#-----------------------------------------------------------------------------------#


#. /${_YCDPARM}/pa6.env
#. /${_YCDPARM}/pa6.fonctions.env

#------------------------------------- Encodage html --------------------------------#
NCODING='"utf-8"'
CSS='"background-color: #00ffff; text-align: center; font-weight: bold"'
#------------------------------------- Encodage html --------------------------------#

# Variable contenant le chemin vers les fichers LOGCTM
FILECTM=/home/talhent/production/AutomatisationDesTaches/LOGCTM
Fist_FILECTM_SAVE=/home/talhent/production/AutomatisationDesTaches/shell/FICHIER_LOG_CTM1.parm
Second_FILECTM_SAVE=/home/talhent/production/AutomatisationDesTaches/shell/FICHIER_LOG_CTM2.parm
DATE_LOGCTM=/home/talhent/production/AutomatisationDesTaches/shell/DATE_DU_DERNIER_LOGCTM.parm
# Variable contenant le chemin du rendu LOGCTM
RENDU=/home/talhent/production/AutomatisationDesTaches/renduCTM.html
# Variable contenant le chemin vers les donnée de parametrage
ADERHPARAM=/home/talhent/production/AutomatisationDesTaches/PARAMETRE.parm
MOTSCLES=/home/talhent/production/AutomatisationDesTaches/MOTSCLES.parm

#-----------------------------------------------------------------------------------#
#                                  FUNCTIONS                                        #
#-----------------------------------------------------------------------------------#

# Condition pour créée un fichier html si elle n'existe pas
ConditionFichierExiste()
{
if test -f $1; then
	rm $1
	else
	touch $1
fi	
}
#-------- Fonction permettant de parcourrir les logs à la recherche d'erreur ------
TestSiVide()
{
	if test -z $1; then
	echo ""
	else
	echo "|| $1"
fi
}

concateneVariableError()
{
Mots='' 
for MotsCles in 'erreur' 'exit [1-9]' 'anormal' 'abnormal' 'jobTest [1-9]' 'code retour [1-9]' 'delai' 'permission denied' 'error' 'depassement' 'cannot' 'can not' 'trop petit' 'err\.' 'rejet'
do
	Mots+="|"$MotsCles""
done
Mots=$(echo $Mots | sed 's/^|//')
echo "${Mots}"
}
ERROR=`concateneVariableError`
DetectionErreur()
{
	EXCLURE='erreur[ ]*=[ ]*0|Edition des erreurs de BMI|Tri des erreurs entre BMM et BME|Warning=Erreur|LIBELLE_ERREUR_CTRLM=$|libelle code erreur|jobTest[ ]*0|exit[ ]*0|code retour[ ]*0|^\+|rm: cannot remove directory|grep[ ]*ERROR|syntax error on line 1 stdin|FakeErrorLoginModule.java|zip error: Nothing to do|mv: cannot rename|VARSORT.*;exit 2 1 2 15|[^1-9] Rows not loaded due to data errors.|Errors allowed: 0|Silent options: FEEDBACK, ERRORS and DISCARDS|whenever sqlerror exit failure rollback|NPQ.VA0TL002.xls.old: Permission denied|pas sortie en erreur|rejetés :.* 000000[ ]*$'
		x=$(egrep -i "$ERROR" $FILECTM/$1 | egrep -vi "$EXCLURE")
 	echo "$(TestSiVide "$x")"
}

FicherRecupere(){
	find $FILECTM/ -mtime -$1 -type f | awk -F / '{print $NF}' > $Fist_FILECTM_SAVE
}
#-----------------------------------------------------------------------------------#
#                                   MAIN                                            #
#-----------------------------------------------------------------------------------#

#jobDebut

ConditionFichierExiste $RENDU
ConditionFichierExiste $Second_FILECTM_SAVE
FicherRecupere 21
#----------------------------------------------------------------- Code pour la mise en forme en html(balise html)-------------------------------------------------------------------------#
echo "<!DOCTYPE html> <html> <head> <meta charset=$ENCODING /> <title>Compte-rendu</title> <style>table, th, td {border: 1px solid black; border-collapse: collapse;}th, td {padding: 10px;}
</style></head><body><table> <tr style=$CSS><td>JOB-CTM</td><td>Description</td><td>Heure début</td><td>Heure fin</td><td>Durée</td><td>Fréquence</td><td>Erreurs </td></tr>" >> $RENDU
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#boucle pour parcourir tous les fichiers ce trouvant dans les dossier appropié.

for FILE in $(< $Fist_FILECTM_SAVE)
do
	LOGFILENAME=$(echo $FILE| awk -F . '{print $1}')
	Fichier=$(echo $FILE| awk -F . '{print $1}')
	LETTRE_ENV=`expr substr $Fichier 1 1`
	case $LETTRE_ENV in
		"X")
		DESC="DESC"$Fichier
		FREQ="FREQ"$Fichier
		PREC="PREC"$Fichier
		;;
		"D")
		Fichier=$(echo $Fichier |  sed 's/^D/X/g')
		DESC="DESC"$Fichier
		FREQ="FREQ"$Fichier
		PREC="PREC"$Fichier
		;;
		"U")
		Fichier=$(echo $Fichier |  sed 's/^U/X/g')
		DESC="DESC"$Fichier
		FREQ="FREQ"$Fichier
		PREC="PREC"$Fichier
		;;
	esac

	                 # *****************((((()))))******************#
				 	 #******** DATES DE FIN ET DEBUT DE JOB ********#
				 	 #******************((((()))))******************#

	#Definition d'une variable date de fin de JOB et début de JOB
	DATE_DEBUT=$(grep "Debut le" $FILECTM/$FILE | awk '{print $6}'| sed -n 1p)
	DATE_FIN=$(grep "Fin le" $FILECTM/$FILE | awk '{print $6}'| sed -n 1p)
	if test -z $DATE_FIN; then 
	DATE_FIN=$(grep "POST TRAITEMENT" $FILECTM/$FILE | awk -F "#" '{print $2}' | cut -d" " -f2)
	fi
	
	# jour début
	jourDebut=$(echo $DATE_DEBUT | cut -d- -f1)
	# jour fin
	jourFin=$(echo $DATE_FIN | cut -d- -f1)
					 # *****************((((()))))******************#
				 	 #******** DATES DE FIN ET DEBUT DE JOB ********#
				 	 #******************((((()))))******************#
	#Definition d'une variable heure de fin de JOB et début de JOB
	HEURE_DEBUT=$(grep "Debut le" $FILECTM/$FILE | awk '{print $8}'| sed -n 1p)
	HEURE_FIN=$(grep "Fin le" $FILECTM/$FILE | awk '{print $8}'| sed -n 1p)
	if test -z $HEURE_FIN; then 
	HEURE_FIN=$(grep "POST TRAITEMENT" $FILECTM/$FILE | awk -F "#" '{print $2}' | cut -d" " -f4)
	fi
	
	#Décomposition de l'heure de début en Hd:Md/Sd
	Hd=$(echo $HEURE_DEBUT | cut -d: -f1)
	Md=$(echo $HEURE_DEBUT | cut -d: -f2)
	Sd=$(echo $HEURE_DEBUT | cut -d: -f3)
	#Décomposition de l'heure de fin en Hf:Mf/Sf
	Hf=$(echo $HEURE_FIN | cut -d: -f1)
	Mf=$(echo $HEURE_FIN | cut -d: -f2)
	Sf=$(echo $HEURE_FIN | cut -d: -f3)
					 # *****************((((()))))******************#
				 	 #******** CALCULE DE LA DUREE DES JOBS ********#
				 	 #******************((((()))))******************#
	if test $jourDebut -eq $jourFin; then
	TempsDebutEnSecond=$(echo $Hd $Md $Sd | awk '{print ($1 * 3600) + ($2 * 60) + $3}')
	TempsFinEnSecond=$(echo $Hf $Mf $Sf | awk '{print ($1 * 3600) + ($2 * 60) + $3}')
	elif test $jourDebut -lt $jourFin; then
	heureFin=$(( $Hf + 24))
	TempsDebutEnSecond=$(echo $Hd $Md $Sd | awk '{print ($1 * 3600) + ($2 * 60) + $3}')
	TempsFinEnSecond=$(echo $heureFin $Mf $Sf | awk '{print ($1 * 3600) + ($2 * 60) + $3}')
	fi
	
	DUREE=$(echo $TempsFinEnSecond $TempsDebutEnSecond | awk '{print $1 - $2 }')
	if test $DUREE -lt 0 || test $DUREE -eq $TempsFinEnSecond
	then
		Tmp="pas defini"
	elif test $DUREE -lt 60
	then
		Tmp="0min $DUREE s"
		
	else
		minute=$(($DUREE / 60 ))
		seconde=$(($DUREE % 60 ))
		Tmp=$minute"min "$seconde"s"
	fi

#----------------------------------------------------------------- Code pour la mise en forme en html(balise html)-------------------------------------------------------------------------#			 
	 echo "<tr><td>$LOGFILENAME</td><td> `grep $DESC $ADERHPARAM | sed -n 1p | cut -d/ -f 2`</td><td>$HEURE_DEBUT</td><td>$HEURE_FIN</td>
	 <td> $Tmp </td><td> `grep $FREQ $ADERHPARAM | sed -n 1p  | cut -d/ -f 2`</td><td>`DetectionErreur $FILE`</td></tr>" >> $RENDU
done
echo "</table> </body> </html>" >> $RENDU
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#jobFin