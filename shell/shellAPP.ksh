#!/bin/ksh

#------------------------------------ DESCRIPTION- ----------------------------------#
# @(#)         Script shell qui sera appelé par un shell principale. 
# @(#) ce script recupere toutes les log applicative dans le repertoir logapp:
# @(#) /dz-pareo-ga/applis/pa6/logapp. les fichiers log recupere seront traités
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

# Variable contenant le chemin vers les fichers LOGAPP
FILEAPP=/home/talhent/production/AutomatisationDesTaches/LOGAPP
Fist_FILEAPP_SAVE=/home/talhent/production/AutomatisationDesTaches/shell/FICHIER_LOG_APP1.parm
SABI=/home/talhent/production/AutomatisationDesTaches/shell/sabi1
Fist_APP_TMP=/home/talhent/production/AutomatisationDesTaches/shell/sabi
Second_FILEAPP_SAVE=/home/talhent/production/AutomatisationDesTaches/shell/FICHIER_LOG_APP2.parm
DATE_LOGAPP=/home/talhent/production/AutomatisationDesTaches/shell/DATE_DU_DERNIER_LOGAPP.parm
# Variable contenant le chemin du rendu LOGAPP
RENDU=/home/talhent/production/AutomatisationDesTaches/renduAPP.html
RENDU_SANS_EXCLUSION=/home/talhent/production/AutomatisationDesTaches/renduAPP_Sans_Exclusion.html
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
	if test ! -z $1; then
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

	x=$(egrep -i "$ERROR" $FILEAPP/$1 | sort | uniq | egrep -vi $EXCLURE )
	echo "$(TestSiVide "$x")"
}

DetectionErreurSansExclusion()
{
EXCLURE='erreur[ ]*=[ ]*0|Edition des erreurs de BMI|Tri des erreurs entre BMM et BME|Warning=Erreur|LIBELLE_ERREUR_CTRLM=$|libelle code erreur|jobTest[ ]*0|exit[ ]*0|code retour[ ]*0|^\+|rm: cannot remove directory|grep[ ]*ERROR|syntax error on line 1 stdin|FakeErrorLoginModule.java|zip error: Nothing to do|mv: cannot rename|VARSORT.*;exit 2 1 2 15|[^1-9] Rows not loaded due to data errors.|Errors allowed: 0|Silent options: FEEDBACK, ERRORS and DISCARDS|whenever sqlerror exit failure rollback|NPQ.VA0TL002.xls.old: Permission denied|pas sortie en erreur|rejetés :.* 000000[ ]*$'

	x=$(egrep -i "$ERROR" $FILEAPP/$1 | sort | uniq)
	echo "$(TestSiVide "$x")"
}
LOG_EXCLURE='XDPA6PMPF_PURGFIC_LISTE_REP_AVANT|XDPA6PMPF_PURGFIC_LISTE_REP_APRES'
FicherRecupere(){
	find $FILEAPP/ -mtime -$1 -type f | awk -F / '{print $NF}' > $Fist_APP_TMP
	egrep -v "$LOG_EXCLURE" $Fist_APP_TMP > $Fist_FILEAPP_SAVE
}

#-----------------------------------------------------------------------------------#
#                                   MAIN                                            #
#-----------------------------------------------------------------------------------#

#jobDebut

ConditionFichierExiste $RENDU
ConditionFichierExiste $RENDU_SANS_EXCLUSION
ConditionFichierExiste $Second_FILEAPP_SAVE
ConditionFichierExiste $SABI
# recuperation des logs sur un intervalle de jours
FicherRecupere 40

# on recupere la date du dernier log exécuté
if test -f $DATE_LOGAPP; then
DERNIER_LOG=$(cat $DATE_LOGAPP)
else
touch $DATE_LOGAPP
fi

#MEGA TEST
for i in $(< $Fist_FILEAPP_SAVE)
do
	MOIS=`ls -l $FILEAPP/$i | awk -F " " '{print $7}'`
	case $MOIS in
		"janvier")
		EXTRACTION_DATE=`ls -lrt $FILEAPP/$i | awk -F " " '{print $7 $6 $8}' | sed 's/://' | sed 's/janvier/01/'`
		echo $i#$EXTRACTION_DATE >> $SABI
		;;
		"fevrier")
		EXTRACTION_DATE=`ls -lrt $FILEAPP/$i | awk -F " " '{print $7 $6 $8}' | sed 's/://' | sed 's/fevrier/02/'`
		echo $i#$EXTRACTION_DATE >> $SABI
		;;
		"mars")
		EXTRACTION_DATE=`ls -lrt $FILEAPP/$i | awk -F " " '{print $7 $6 $8}' | sed 's/://' | sed 's/mars/03/'`
		echo $i#$EXTRACTION_DATE >> $SABI
		;;
		"avril")
		EXTRACTION_DATE=`ls -lrt $FILEAPP/$i | awk -F " " '{print $7 $6 $8}' | sed 's/://' | sed 's/avril/04/'`
		echo $i#$EXTRACTION_DATE >> $SABI
		;;
		"mai")
		EXTRACTION_DATE=`ls -lrt $FILEAPP/$i | awk -F " " '{print $7 $6 $8}' | sed 's/://' | sed 's/mai/05/'`
		echo $i#$EXTRACTION_DATE >> $SABI
		;;
		"juin")
		EXTRACTION_DATE=`ls -lrt $FILEAPP/$i | awk -F " " '{print $7 $6 $8}' | sed 's/://' | sed 's/juin/06/'`
		echo $i#$EXTRACTION_DATE >> $SABI
		;;
		"juillet")
		EXTRACTION_DATE=`ls -lrt $FILEAPP/$i | awk -F " " '{print $7 $6 $8}' | sed 's/://' | sed 's/juillet/07/'`
		echo $i#$EXTRACTION_DATE >> $SABI
		;;
		"aout")
		EXTRACTION_DATE=`ls -lrt $FILEAPP/$i | awk -F " " '{print $7 $6 $8}' | sed 's/://' | sed 's/aout/08/'`
		echo $i#$EXTRACTION_DATE >> $SABI
		;;
		"septembre")
		EXTRACTION_DATE=`ls -lrt $FILEAPP/$i | awk -F " " '{print $7 $6 $8}' | sed 's/://' | sed 's/septembre/09/'`
		echo $i#$EXTRACTION_DATE >> $SABI
		;;
		"octobre")
		EXTRACTION_DATE=`ls -lrt $FILEAPP/$i | awk -F " " '{print $7 $6 $8}' | sed 's/://' | sed 's/octobre/10/'`
		echo $i#$EXTRACTION_DATE >> $SABI
		;;
		"novembre")
		EXTRACTION_DATE=`ls -lrt $FILEAPP/$i | awk -F " " '{print $7 $6 $8}' | sed 's/://' | sed 's/novembre/11/'`
		echo $i#$EXTRACTION_DATE >> $SABI
		;;
		"decembre")
		EXTRACTION_DATE=`ls -lrt $FILEAPP/$i | awk -F " " '{print $7 $6 $8}' | sed 's/://' | sed 's/decembre/12/'`
		echo $i#$EXTRACTION_DATE >> $SABI
		;;
	esac
done

# recuperation des logs en fonction de la date du dernier log
for i in $(< $SABI)
do
	DATE_COURANT=$(echo $i | awk -F "#" '{print $NF}')
	if test $DATE_COURANT -ge $DERNIER_LOG; then
	echo $i >> $Second_FILEAPP_SAVE
	fi
done

#----------------------------------------------------------------- Code pour la mise en forme en html(balise html)-------------------------------------------------------------------------#
echo "<!DOCTYPE html> <html> <head> <meta charset=$ENCODING /> <title>Compte-rendu</title> <style>table, th, td {border: 1px solid black; border-collapse: collapse;}th, td {padding: 10px;}
</style></head><body><div><a href="`echo $RENDU_SANS_EXCLUSION`">Rendu avec exclusion de faux erreurs</a></div>
<table> <tr style=$CSS><td>JOB-APP</td><td>Description</td><td>Heure début</td><td>Heure fin</td><td>Durée</td><td>Fréquence</td><td>Erreurs </td></tr>" >> $RENDU
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#

#----------------------------------------------------------------- Code pour la mise en forme en htmlsans eclusion (balise html)-------------------------------------------------------------------------#
echo "<!DOCTYPE html> <html> <head> <meta charset=$ENCODING /> <title>Compte-rendu</title> <style>table, th, td {border: 1px solid black; border-collapse: collapse;}th, td {padding: 10px;}
</style></head><body><div><a href="`echo $RENDU`">Rendu sans exclusion de faux erreurs</a></div>
<table> <tr style=$CSS><td>JOB-APP</td><td>Description</td><td>Heure début</td><td>Heure fin</td><td>Durée</td><td>Fréquence</td><td>Erreurs </td></tr>" >> $RENDU_SANS_EXCLUSION
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#boucle pour parcourir tous les fichiers ce trouvant dans les dossier appropié.
OLDIFS=$IFS
IFS=$'\n'
for fiche in $(< $SABI)
do
	FILE=$(echo $fiche | awk -F "#" '{print $1}')
	Fichier=$(echo $fiche | awk -F . '{print $1}' | cut -d_ -f1,2)
	LETTRE_ENV=`expr substr $Fichier 1 1`
	case $LETTRE_ENV in
		"X")
		Fichier=$(echo $Fichier |  sed 's/^X/X/g')
		DESC="DESC"$Fichier
		FREQ="FREQ"$Fichier
		PREC="PREC"$Fichier
		;;
		"D")
		Fichier=$(echo $Fichier |  sed 's/^D/X/g')
		;;
		"U")
		Fichier=$(echo $Fichier |  sed 's/^U/X/g')
		;;
	esac

                 	 # *****************((((()))))******************#
				 	 #******** DATES DE FIN ET DEBUT DE JOB ********#
				 	 #******************((((()))))******************#

	#Definition d'une variable date de fin de JOB et début de JOB
	DATE_DEBUT=$(grep "JOB :.* DATE :" $FILEAPP/$FILE | awk '{print $6}' | sed -n 1p)
	DATE_FIN=$(grep "JOB :.* DATE :" $FILEAPP/$FILE | awk '{print $6}' | sed -n 2p)
	jourDebut=$(echo $DATE_DEBUT | cut -d/ -f3)
	jourFin=$(echo $DATE_FIN | cut -d/ -f3)
	if test -z $DATE_DEBUT || test -z $DATE_FIN; then 
	jourDebut=$(grep -E ^"Run began" $FILEAPP/$FILE | awk '{print $6}')
	jourFin=$(grep -E ^"Run ended" $FILEAPP/$FILE | awk '{print $6}')
	fi
					 # *****************((((()))))******************#
				 	 #******** DATES DE FIN ET DEBUT DE JOB ********#
				 	 #******************((((()))))******************#
	#Definition d'une variable heure de fin de JOB et début de JOB
	HEURE_DEBUT=$(grep "JOB :.* DATE :" $FILEAPP/$FILE | awk '{print $7}' | sed -n 1p)
	HEURE_FIN=$(grep "JOB :.* DATE :" $FILEAPP/$FILE | awk '{print $7}' | sed -n 2p)
	if test -z $HEURE_DEBUT || test -z $HEURE_FIN; then 
	HEURE_DEBUT=$(grep -E ^"Run began" $FILEAPP/$FILE | awk '{print $7}')
	HEURE_FIN=$(grep -E ^"Run ended" $FILEAPP/$FILE | awk '{print $7}')
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
	 echo "<tr><td>" $(echo $FILE | awk -F . '{print $1}')" </td><td> `grep $Fichier $ADERHPARAM | sed -n 2p | cut -d/ -f 2`</td><td>$HEURE_DEBUT</td><td>$HEURE_FIN</td>
	 <td>$Tmp</td><td> `grep $Fichier $ADERHPARAM | sed -n 3p | cut -d/ -f 2`</td><td>`DetectionErreur $FILE`</td></tr>" >> $RENDU

#----------------------------------------------------------------- Code pour la mise en forme en html(balise html)-------------------------------------------------------------------------#		 
	 echo "<tr><td>" $(echo $FILE | awk -F . '{print $1}')" </td><td> `grep $Fichier $ADERHPARAM | sed -n 2p | cut -d/ -f 2`</td><td>$HEURE_DEBUT</td><td>$HEURE_FIN</td>
	 <td>$Tmp</td><td> `grep $Fichier $ADERHPARAM | sed -n 3p | cut -d/ -f 2`</td><td>`DetectionErreurSansExclusion $FILE`</td></tr>" >> $RENDU_SANS_EXCLUSION
done
IFS=$OLDIFS
echo "</table> </body> </html>" >> $RENDU
echo "</table> </body> </html>" >> $RENDU_SANS_EXCLUSION
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
cat $SABI | awk -F "#" '{print $NF}' | tail -1 > $DATE_LOGAPP
#jobFin