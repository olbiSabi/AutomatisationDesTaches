#!/bin/ksh


#------------------------------------ DESCRIPTION- ----------------------------------#
# @(#)                     SHELL PRINCIPAL DU SUIBI DE PRODUCTION 
# @(#) This script exécute the applicative, CTM SHELL and use CFT to send FILE to U:
#---------------------------------- AUTEUR ET DATE ----------------------------------#
# @(#) Auteur: Sabi ONIANKITAN
# @(#) Date Creation:
#------------------------------------ HISTORIQUE ------------------------------------#
# @(#)|    VERSION   |      NOM     |  PRENOM   |  DATE DE MISE A JOUR  |
#     |     V0.1     |  ONIANKITAN  |   SABI    |  29/03/2021           | 
#-----------------------------------------------------------------------------------#


#. /${_YCDPARM}/pa6.env
#. /${_YCDPARM}/pa6.fonctions.env


# Variable contenant le chemin vers le shell APP
SHELL_APP=/home/talhent/production/AutomatisationDesTaches/shell/shellAPP.ksh
# Variable contenant le chemin vers le shell CTM
SHELL_CTM=/home/talhent/production/AutomatisationDesTaches/shell/shellCTM.ksh
# Variable contenant le chemin vers les fichier HTML à envoyé par CFT
RENDU_APP=/home/talhent/production/AutomatisationDesTaches/renduAPP.html
RENDU_CTM=/home/talhent/production/AutomatisationDesTaches/renduCTM.html


#-----------------------------------------------------------------------------------#
#                                  FUNCTIONS                                        #
#-----------------------------------------------------------------------------------#
fl_envoi_cft()
{
set -x
        #jobEtape "fl_envoi_cft : Envoi fichier via CFT"
        cft.sh send -m $1 -f $2
        #jobTest "$?" "fl_envoi_cft : Pb envoi fichier via CFT"
}

#-----------------------------------------------------------------------------------#
#                                   MAIN                                            #
#-----------------------------------------------------------------------------------#

"$SHELL_APP"
"$SHELL_CTM"