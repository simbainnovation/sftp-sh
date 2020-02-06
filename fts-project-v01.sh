#!/bin/bash
#------------------------------------------------------------------------------------------------------------
# fts_script_version	v02
strScriptVersion=v02
# fts_script_author	miroslav.hruby@homecreditcfc.cn
# fts_script_date	20190925
# fts_script_note	generates/deletes fts project structure and user accounts and modifies sshd_config file
# fts_script_pars	mandatory_parameters:

# Parametr $1 - CREATE/DELETE - PROJECT ID
# par $1		ProjectId	        		#strProId (sr-00000000)	#string sr- or cn- + 6 numbers 
strProId=$1

# Parametr $2 - CREATE/DELETE - Number of Client Accounts/Delete Project
# par $2		Number of client accounts		#numCliNumber			#number 1-999
# parr $2		D					Indicates deletion of the defined project
numCliNumber=$2

# Parametr $3 - CREATE - Number of Staff Accounts
# par $3		Number of staff accounts		#numStaNumber			#number 1-999
numStaNumber=$3

# Parametr $4 - CREATE - Number of GBs Disk Quota
# par $4		Project account disk quota in GBs	#numProQta				#number 1-5 (default 2)  
numProQta=$4
#------------------------------------------------------------------------------------------------------------

strDate=$( date +%Y%m%d )
strDay=$( date +%Y%m%d )-$( date +%s )

logDir=/var/log
logFile=$logDir/fts-$strDate.log

strUsrRoot=root

strDirEtc=/etc
strDirHome=/home
strDirProjects=${strDirHome,,}/projects
strDirProjectsInfo=${strDirProjects,,}/projects_info
strDirSsh=${strDirEtc,,}/ssh

strFilePasswd=passwd
strFileGroup=group
strFileSshd=sshd_config
strFileSshdCfg=sshd_config
strFileSshdCfg_Bck=sshd_config_bak
strFileSshdCfg_Tmp=sshd_config_tmp

strDirUpload=upload
strDirDownload=download
strDirSshKey=.ssh

function fn_check_par1() {

    do_strProId=${strProId,,}

    do_strDay=${strDay,,}
    do_strProIdType=${do_strProId:0:3}
    do_strProIdNum=${do_strProId: -6}

    LogMsgHeadDOne="FTS-PRO-PAR1_${do_strDay,,}"
    do_LogWriteDOne="logger -s -t ${LogMsgHeadDOne}"

#check $1 - project Id
    if [ -z ${do_strProId,,} ]; then
        LogMsgHeadDOne="$( date +%H:%M:%S ): 1st parameter ProjetId not defined! Script stopped!"
        echo "$LogMsgHeadCPar:$LogMsgHeadDOne"
        echo "$LogMsgHeadCPar:$LogMsgHeadDOne" >> ${logFile,,}
        $do_LogWriteDOne $LogMsgHeadDOne
        exit 1
    fi

#$1 - len of string
     if [ ${#do_strProId} -ne 9 ]; then
        LogMsgHeadDOne="$( date +%H:%M:%S ): Not correct 1st parameter ProjectId [$do_strProId] not 9 characters! Script stopped."
        echo "$LogMsgHeadCPar:$LogMsgHeadDOne"
        echo "$LogMsgHeadCPar:$LogMsgHeadDOne" >> ${logFile,,}
        $do_LogWriteDOne $LogMsgHeadDOne
        exit 1
     fi

#$1 - project Id type
    if ! [ ${do_strProIdType} == "sr-" -o ${do_strProIdType} == "cn-" ]; then
        LogMsgHeadDOne="$( date +%H:%M:%S ): Not correct 1st parameter ProjectId [$do_strProId] can be only sr-xxxxxx or cn-xxxxxx! Script stopped!"
        echo "$LogMsgHeadCPar:$LogMsgHeadDOne"
        echo "$LogMsgHeadCPar:$LogMsgHeadDOne" >> ${logFile,,}
        $do_LogWriteDOne $LogMsgHeadDOne
        exit 1
    fi

#$1 - last 6 characters are digits?
    if ! [[ ! -n ${do_strProIdNum//[0-9]/} ]]; then
        LogMsgHeadDOne="$( date +%H:%M:%S ): Not correct 1st parameter ProjectId [$do_strProId] last 6 characters must be numbers! Script stopped."
        echo "$LogMsgHeadCPar:$LogMsgHeadDOne"
        echo "$LogMsgHeadCPar:$LogMsgHeadDOne" >> ${logFile,,}
        $do_LogWriteDOne $LogMsgHeadDOne
        exit 1
    fi

}

function fn_check_pars() {

    loc_strPar1=$1
    loc_numPar2=$2
    loc_numPar3=$3
    loc_numPar4=$4

    loc_strDay=${strDay,,}
    loc_strProIdType=${loc_strPar1:0:3}
    loc_strProIdNum=${loc_strPar1: -6}

    LogMsgHeadCPar="FTS-PRO-PAR_${strDay,,}"
    loc_LogWriteCPar="logger -s -t ${LogMsgHeadCPar}"

#check $1 - project Id
    if [ -z ${loc_strPar1,,} ]; then
        loc_LogMsgInfo="$( date +%H:%M:%S ): 1st parameter ProjetId not defined! Script stopped!"
        echo "$LogMsgHeadCPar:$loc_LogMsgInfo"
        echo "$LogMsgHeadCPar:$loc_LogMsgInfo" >> ${logFile,,}
        $loc_LogWriteCPar $loc_LogMsgInfo
        exit 1
    fi

#$1 - len of string
     if [ ${#loc_strPar1} -ne 9 ]; then
        loc_LogMsgInfo="$( date +%H:%M:%S ): Not correct 1st parameter ProjectId [$loc_strPar1] not 9 characters! Script stopped."
        echo "$LogMsgHeadCPar:$loc_LogMsgInfo"
        echo "$LogMsgHeadCPar:$loc_LogMsgInfo" >> ${logFile,,}
        $loc_LogWriteCPar $loc_LogMsgInfo
        exit 1
     fi

#$1 - project Id type
    if ! [ ${loc_strProIdType} == "sr-" -o ${loc_strProIdType} == "cn-" ]; then
        loc_LogMsgInfo="$( date +%H:%M:%S ): Not correct 1st parameter ProjectId [$loc_strPar1] can be only sr-xxxxxx or cn-xxxxxx! Script stopped!"
        echo "$LogMsgHeadCPar:$loc_LogMsgInfo"
        echo "$LogMsgHeadCPar:$loc_LogMsgInfo" >> ${logFile,,}
        $loc_LogWriteCPar $loc_LogMsgInfo
        exit 1
    fi

#$1 - last 6 characters are digits?
    if ! [[ ! -n ${loc_strProIdNum//[0-9]/} ]]; then
        loc_LogMsgInfo="$( date +%H:%M:%S ): Not correct 1st parameter ProjectId [$loc_strPar1] last 6 characters must be numbers! Script stopped."
        echo "$LogMsgHeadCPar:$loc_LogMsgInfo"
        echo "$LogMsgHeadCPar:$loc_LogMsgInfo" >> ${logFile,,}
        $loc_LogWriteCPar $loc_LogMsgInfo
        exit 1
    fi

#check $2 defined number of client accounts
    if [ -z ${loc_numPar2} ]; then
        loc_LogMsgInfo="$( date +%H:%M:%S ): 2nd parameter NumberOfClientAccounts not defined! Script stopped."
        echo "$LogMsgHeadCPar:$loc_LogMsgInfo"
        echo "$LogMsgHeadCPar:$loc_LogMsgInfo" >> ${logFile,,}
        $loc_LogWriteCPar $loc_LogMsgInfo
        exit 1
    else
        if ! [[ ! -n ${loc_numPar2//[0-9]/} ]]; then
            loc_LogMsgInfo="$( date +%H:%M:%S ): 2nd parameter NumberOfClientAccounts [$loc_numPar2] must be the whole number between 1-999! Script stopped."
            echo "$LogMsgHeadCPar:$loc_LogMsgInfo"
            echo "$LogMsgHeadCPar:$loc_LogMsgInfo" >> ${logFile,,}
            $loc_LogWriteCPar $loc_LogMsgInfo
            exit 1
        fi
        if ! [ ${loc_numPar2} -ge 1 -a ${loc_numPar2} -le 999 ]; then
            loc_LogMsgInfo="$( date +%H:%M:%S ): 2nd parameter NumberOfClientAccounts [$loc_numPar2] must be the whole number between 1-999!! Script stopped."
            echo "$LogMsgHeadCPar:$loc_LogMsgInfo"
            echo "$LogMsgHeadCPar:$loc_LogMsgInfo" >> ${logFile,,}
            $loc_LogWriteCPar $loc_LogMsgInfo
            exit 1
        fi
    fi

#check $3 - defined number of staff accounts
    if [ -z ${loc_numPar3} ]; then
        loc_LogMsgInfo="$( date +%H:%M:%S ): 3rd parameter NumberOfStaffAccounts not defined! Script stopped."
        echo "$LogMsgHeadCPar:$loc_LogMsgInfo"
        echo "$LogMsgHeadCPar:$loc_LogMsgInfo" >> ${logFile,,}
        $loc_LogWriteCPar $loc_LogMsgInfo
        exit 1
    else
        if ! [[ ! -n ${loc_numPar3//[0-9]/} ]]; then
            loc_LogMsgInfo="$( date +%H:%M:%S ): 3rd parameter NumberOfStaffAccounts [$loc_numPar3] must be the whole number between 1-999! Script stopped."
            echo "$LogMsgHeadCPar:$loc_LogMsgInfo"
            echo "$LogMsgHeadCPar:$loc_LogMsgInfo" >> ${logFile,,}
            $loc_LogWriteCPar $loc_LogMsgInfo
            exit 1
        fi
        if ! [ ${loc_numPar3} -ge 1 -a ${loc_numPar3} -le 999 ]; then
            loc_LogMsgInfo="$( date +%H:%M:%S ): 3rd parameter NumberOfStaffAccounts [$loc_numPar3] must be the whole number between 1-999! Script stopped."
            echo "$LogMsgHeadCPar:$loc_LogMsgInfo"
            echo "$LogMsgHeadCPar:$loc_LogMsgInfo" >> ${logFile,,}
            $loc_LogWriteCPar $loc_LogMsgInfo
            exit 1
        fi
    fi

#check $4 - defined project quota
    if [ -z ${loc_numPar4} ]; then
        loc_LogMsgInfo="$( date +%H:%M:%S ): 4th parameter DiskQuota not defined! Set default value 2GB!."
        echo "$LogMsgHeadCPar:$loc_LogMsgInfo"
        echo "$LogMsgHeadCPar:$loc_LogMsgInfo" >> ${logFile,,}
        $loc_LogWriteCPar $loc_LogMsgInfo
        exit 1
    else
        if ! [[ ! -n ${loc_numPar4//[0-9]/} ]]; then
            loc_LogMsgInfo="$( date +%H:%M:%S ): 4th parameter DiskQuota [$loc_numPar4] must be the whole number between 1-5! Script stopped."
            echo "$LogMsgHeadCPar:$loc_LogMsgInfo"
            echo "$LogMsgHeadCPar:$loc_LogMsgInfo" >> ${logFile,,}
            $loc_LogWriteCPar $loc_LogMsgInfo
            exit 1
        fi
        if ! [ ${loc_numPar4} -ge 1 -a ${loc_numPar4} -le 5 ]; then
            loc_LogMsgInfo="$( date +%H:%M:%S ): 4th parameter DiskQuota [$loc_numPar4] must be the whole number between 1-5! Script stopped."
            echo "$LogMsgHeadCPar:$loc_LogMsgInfo"
            echo "$LogMsgHeadCPar:$loc_LogMsgInfo" >> ${logFile,,}
            $loc_LogWriteCPar $loc_LogMsgInfo
            exit 1
        fi
    fi
}

function fn_check_pro_dirs () {
#checks if projects and projects_info dirs exist, create new one if doesn't
#par1 Projects dir name
#par2 Projects_info dir name

    cd_strPar1=$1
	cd_strPar2=$2
	cd_strPar3=$3

    cd_strProId=${cd_strPar1,,}	
	cd_strDirProjects=${cd_strPar2,,}
	cd_strDirProjectsInfo=${cd_strPar3,,}
	
    cd_LogMsgHeadPDir="${cd_strProId,,}-PDIR_${strDay,,}"
    cd_LogWritePDir="logger -s -t ${cd_LogMsgHeadPDir}"
	
##create new projects dir if does not exists
    if ! [ -d "${cd_strDirProjects,,}" ]; then
        cd_LogMsgInfo="$( date +%H:%M:%S ): FTS projects dir ${cd_strDirProjects,,} does not exist, creating new one."
        echo "${cd_LogMsgHeadPDir}:${cd_LogMsgInfo}" >> ${logFile,,}
        $cd_LogWritePDir $cd_LogMsgInfo
		
        mkdir -p ${cd_strDirProjects,,}
        chown ${strUsrRoot} ${cd_strDirProjects,,}
        chmod 744 ${cd_strDirProjects,,}
		
    else
        cd_LogMsgInfo="$( date +%H:%M:%S ): FTS projects dir ${cd_strDirProjects,,} already exists."
        echo "${cd_LogMsgHeadPDir}:${cd_LogMsgInfo}" >> ${logFile,,}
        $cd_LogWritePDir $cd_LogMsgInfo
    fi

##create new projects_info dir if does not exists
    if ! [ -d "${cd_strDirProjectsInfo,,}" ]; then
        cd_LogMsgInfo="$( date +%H:%M:%S ): FTS projects info dir ${cd_strDirProjectsInfo,,} does not exist, creating new one."
        echo "$cd_LogMsgHeadPDir:$cd_LogMsgInfo" >> ${logFile,,}
        $cd_LogWritePDir $cd_LogMsgInfo
        mkdir -p ${cd_strDirProjectsInfo,,}
        chown ${strUsrRoot} ${cd_strDirProjectsInfo,,}
        chmod 700 ${cd_strDirProjectsInfo,,}
    else
        cd_LogMsgInfo="$( date +%H:%M:%S ): FTS projects info dir ${cd_strDirProjectsInfo,,} already exists."
        echo "$cd_LogMsgHeadPDir:$cd_LogMsgInfo" >> ${logFile,,}
        $cd_LogWritePDir $cd_LogMsgInfo
   fi

}

function fn_delete_project() {
#/etc/passwd
#/etc/group
#/etc/ssh/sshd_config
#/home/projects/%project_dir%
#par1 = strProId
#par2 = strDay

    dp_par1=$1
    dp_par2=$2

	dp_strProId=${dp_par1,,}
	dp_strDay=${dp_par2,,}
	
	dp_strDirProject=${strDirProjects,,}/${dp_strProId,,}
	dp_strFilePasswd=${strDirEtc,,}/${strFilePasswd,,}
	dp_strFileGroup=${strDirEtc,,}/${strFileGroup,,}
	dp_strFileSshdCfg=${strDirSsh,,}/${strFileSshdCfg,,}
	dp_strFileSshdCfg_Bck=${strDirProjectsInfo,,}/${dp_strProId,,}-${dp_strDay,,}_${strFileSshdCfg_Bck,,}_del
	tmp_strFileSshdCfg=${strDirProjectsInfo,,}/tmp_${dp_strProId,,}-${dp_strDay,,}_${strFileSshdCfg,,}

    dp_LogMsgHeadDPro="${dp_strProId,,}-DELP_${dp_strDay,,}"
    dp_LogWriteDPro="logger -s -t ${dp_LogMsgHeadDPro}"
	
    dp_LogMsgInfo="$( date +%H:%M:%S ): Deleting ${dp_strProId,,} project!"
    echo "$dp_LogMsgHeadDPro:$dp_LogMsgInfo" >> ${logFile,,}
    $dp_LogWriteDPro $dp_LogMsgInfo	

#if exist delete old project account(s)
    n=1

    for usrName in $(awk 'BEGIN{FS=":"}{print $1}' < "${dp_strFilePasswd,,}" )
        do
             if [[ ${usrName:0:9} == ${dp_strProId} ]]; then
			
                    dp_LogMsgInfo="$( date +%H:%M:%S ): Deleting ${usrName} account!"
                    echo "$dp_LogMsgHeadDPro:$dp_LogMsgInfo" >> ${logFile,,}
                    $dp_LogWriteDPro $dp_LogMsgInfo

                    userdel -fr $usrName

            fi
  	    let "n += 1"
        done

#if exists delete project staff group
    n=1

    for grpName in $(awk 'BEGIN{FS=":"}{print $1}' < "${dp_strFileGroup,,}" )
        do
             if [[ ${grpName:0:9} == ${dp_strProId} ]]; then
			
                    dp_LogMsgInfo="$( date +%H:%M:%S ): Deleting ${grpName} staff group!"
                    echo "$dp_LogMsgHeadDPro:$dp_LogMsgInfo" >> ${logFile,,}
                    $dp_LogWriteDPro $dp_LogMsgInfo

                    groupdel $grpName

            fi
  	    let "n += 1"
        done

#if exists delete projet information from sshd_config file

    dp_LogMsgInfo="$( date +%H:%M:%S ): Copy sshd_config file to ${dp_strFileSshdCfg_Bck,,} backup file."
    echo "$dp_LogMsgHeadDPro:$dp_LogMsgInfo" >> ${logFile,,}
    $dp_LogWriteDPro $dp_LogMsgInfo

    cp ${dp_strFileSshdCfg,,} ${dp_strFileSshdCfg_Bck,,}

    dp_LogMsgInfo="$( date +%H:%M:%S ): Changing sshd_config file - removing ${dp_strProId,,} project information!"
    echo "$dp_LogMsgHeadDPro:$dp_LogMsgInfo" >> ${logFile,,}
    $dp_LogWriteDPro $dp_LogMsgInfo

    grep -v "#${dp_strProId}" ${dp_strFileSshdCfg,,} > ${tmp_strFileSshdCfg,,}

    cp ${tmp_strFileSshdCfg,,} ${dp_strFileSshdCfg,,}
    rm -rf ${tmp_strFileSshdCfg,,}

    dp_LogMsgInfo="$( date +%H:%M:%S ): Changed sshd_config file - removed ${dp_strProId} project information!"
    echo "$dp_LogMsgHeadDPro:$dp_LogMsgInfo" >> ${logFile,,}
    $dp_LogWriteDPro $dp_LogMsgInfo

##restarting sshd service

    dp_LogMsgInfo="$( date +%H:%M:%S ): Restarting sshd daemon."
    echo "$dp_LogMsgHeadDPro:$dp_LogMsgInfo" >> ${logFile,,}
    $dp_LogWriteDPro $dp_LogMsgInfo

    service sshd restart

##if exists delete project dir

    if [ -d dp_strDirProject ]; then

        rm -rf ${dp_strDirProject,,}

        dp_LogMsgInfo="$( date +%H:%M:%S ): Deleted old ${dp_strDirProject,,} project directory!"
        echo "$dp_LogMsgHeadDPro:$dp_LogMsgInfo" >> ${logFile,,}
        $dp_LogWriteDPro $dp_LogMsgInfo

    else

        dp_LogMsgInfo="$( date +%H:%M:%S ): ${dp_strDirProject,,} project directory does not exist yet!"
        echo "$dp_LogMsgHeadDPro:$ddp_LogMsgInfo" >> ${logFile,,}
        $dp_LogWriteDPro $dp_LogMsgInfo
    
    fi

}

function fn_delete_account() {
#delete fts account if already exists
#fn_delete_account ${strProId,,} ${strDay,,} ${strUsrName,,} ${strFile_PASSWD,,}
#loc_par1 = strProId
#loc_par2 = strDay
#loc_par3 = strUsrName

    du_par1=$1
    du_par2=$2
    du_par3=$3

    du_strProId=${du_par1,,}
    du_strDay=${du_par2,,}
    du_strUsrName=${du_par3,,}
    du_strFilePasswd=${strDirEtc,,}/${strFilePasswd,,}

    du_LogMsgHeadDAcc="${du_strProId,,}-DACC_${du_strDay,,}"
    du_LogWriteDelAcc="logger -s -t ${du_LogMsgHeadDAcc}"

    n=1
    for usrName in $(awk 'BEGIN{FS=":"}{print $1}' < "${du_strFilePasswd,,}" )
	do
		if [[ "$usrName" == ${du_strUsrName,,} ]]; then
		
				du_LogMsgInfo="$( date +%H:%M:%S ): Deleting old ${usrName} account!"
				echo "$du_LogMsgHeadDAcc:$du_LogMsgInfo" >> ${logFile,,}
				$du_LogWriteDelAcc $du_LogMsgInfo

				userdel -fr $usrName

		fi
	    let "n += 1"
	done
}

function fn_conf_sshd() {
##configure sshd service configuration - /etc/ssh/sshd_config
## par1 = ProjectId
## par2 = strDay (time stamp info when ran)
## par3 = Group created for ProjectId staff
 
    sshd_par1=$1
    sshd_par2=$2
    sshd_par3=$3

    sshd_strProId=${sshd_par1,,}
    sshd_strDay=${sshd_par2,,}
    sshd_strSta_SSH_GROUP_NAME=${sshd_par3,,}

    sshd_strFILE_SSHD_CFG=${strDirSsh,,}/${strFileSshd,,}
    sshd_strFILE_SSHD_CFG_BCK=${strDirProjectsInfo,,}/${sshd_strProId,,}-${sshd_strDay,,}_${strFileSshd,,}_bak
    tmp_strFILE_SSHD_CFG=${strDirProjectsInfo,,}/tmp_${sshd_strProId,,}-${sshd_strDay,,}_${strFileSshd,,}

    sshd_LogMsgHeadSshd="${sshd_strProId,,}-SSHD_${sshd_strDay,,}"
    sshd_LogWriteSsh="logger -s -t ${sshd_LogMsgHeadSshd}"

    sshd_LogMsgInfo="$( date +%H:%M:%S ): Copy sshd_config file to ${sshd_strFILE_SSHD_CFG_BCK,,} backup file."
    echo "$sshd_LogMsgHeadSshd:$sshd_LogMsgInfo" >> ${logFile,,}
    $sshd_LogWriteSsh $sshd_LogMsgInfo

    cp ${sshd_strFILE_SSHD_CFG,,} ${sshd_strFILE_SSHD_CFG_BCK,,}

    sshd_LogMsgInfo="$( date +%H:%M:%S ): Changing sshd_config file - adding ${sshd_strProId,,} project information!"
    echo "$sshd_LogMsgHeadSshd:$sshd_LogMsgInfo" >> ${logFile,,}
    $sshd_LogWriteSsh $sshd_LogMsgInfo

    grep -v "#${sshd_strProId}" ${sshd_strFILE_SSHD_CFG,,} > ${tmp_strFILE_SSHD_CFG,,}

    echo ""
    echo "#Project info                                        #${sshd_strProId}" >> ${tmp_strFILE_SSHD_CFG,,}
    echo "Match group ${sshd_strSta_SSH_GROUP_NAME,,}                           #${sshd_strProId}" >> ${tmp_strFILE_SSHD_CFG,,}
    echo "	ChrootDirectory %h                            #${sshd_strProId}" >> ${tmp_strFILE_SSHD_CFG,,}
    echo "	X11Forwarding no                              #${sshd_strProId}" >> ${tmp_strFILE_SSHD_CFG,,}
    echo "	AllowTcpForwarding no                         #${sshd_strProId}" >> ${tmp_strFILE_SSHD_CFG,,}
    echo "	ForceCommand internal-sftp                    #${sshd_strProId}" >> ${tmp_strFILE_SSHD_CFG,,}

    cp ${tmp_strFILE_SSHD_CFG,,} ${sshd_strFILE_SSHD_CFG,,}
    rm -rf ${tmp_strFILE_SSHD_CFG,,}

    sshd_LogMsgInfo="$( date +%H:%M:%S ): Changed sshd_config file - added ${sshd_strProId} project information!"
    echo "$sshd_LogMsgHeadSshd:$sshd_LogMsgInfo" >> ${logFile,,}
    $sshd_LogWriteSsh $sshd_LogMsgInfo

}

function fn_create_project() {
#function creating specific project
#all parameters are mandatory
#loc_Par1 = project name / id
#loc_Par2 = info how many client accounts has to be created
#loc_Par3 = info how many staff (internal) accounts has to be created
#loc_Par4 = disk quota defined for all project accounts

    loc_par1=$1
    loc_par2=$2
    loc_par3=$3
    loc_par4=$4

    loc_strProId=${loc_par1,,}
    loc_numCliNumber=${loc_par2,,}
    loc_numStaNumber=${loc_par3,,}
    loc_numProQta=${loc_par4,,}

    loc_strDay=${strDay,,}

    let loc_numProNumber=${loc_strProId#*-}+1000000

    loc_strUsr_ROOT=root
    loc_strUsr_SHELL=/usr/lib/sftp-server
    loc_strCli_SSH_GROUP_NAME=sftponly
    loc_strSta_SSH_GROUP_NAME=${loc_strProId,,}-staff

    loc_strDIR_Home=${strDirHome,,}
    loc_strDIR_Projects=${strDirProjects,,}
    loc_strDIR_ProjectInfo=${strDirProjectsInfo,,}

    loc_strDIR_Project=${strDirProjects}/${loc_strProId,,}

    loc_strFILE_GROUP=/etc/group

    loc_strFILE_ProCliCsv=${strDirProjectsInfo,,}/${loc_strProId,,}-${loc_strDay}_client_list.csv
    loc_strFILE_ProStaCsv=${strDirProjectsInfo,,}/${loc_strProId,,}-${loc_strDay}_staff_list.csv
    tmp_strFILE_ProCliPasswd=${strDirProjectsInfo,,}/tmp_${loc_strProId,,}-${loc_strDay}_clipasswd.txt
    tmp_strFILE_ProStaPasswd=${strDirProjectsInfo,,}/tmp_${loc_strProId,,}-${loc_strDay}_stapasswd.txt
	
    loc_numQtaNoSoftLimit=0
    loc_numQtaNoHardLimit=0
    loc_numQtaSoftLimit=${loc_numProQta}
    let loc_numQtaHardLimit=${loc_numProQta}+1
    loc_strQtaLimits="bsoft=${loc_numQtaSoftLimit}g bhard=${loc_numQtaHardLimit}g"
	
    loc_LogMsgHeadCPro=${loc_strProId,,}"-CPro_"${strDay}
    loc_LogWriteCPro="logger -s -t ${loc_LogMsgHeadCPro}"

    loc_LogMsgInfo="$( date +%H:%M:%S ): Creating FTS project ${loc_strProId} for ${loc_numCliNumber} client and ${loc_numStaNumber} staff account(s) with ${loc_numQtaSoftLimit}GB disk quota."
    echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
    $loc_LogWriteCPro $loc_LogMsgInfo

##create project directory
    if [ -d ${loc_strDIR_Project,,} ]; then

        loc_LogMsgInfo="$( date +%H:%M:%S ): Old ${loc_strDIR_Project,,} project directory will be deleted!"
        echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
        $loc_LogWriteCPro $loc_LogMsgInfo

        rm -rf ${loc_strDIR_Project,,}

        loc_LogMsgInfo="$( date +%H:%M:%S ): Creating new ${loc_strDIR_Project,,} project directory."
        echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
        $loc_LogWriteCPro $loc_LogMsgInfo

        mkdir -p ${loc_strDIR_Project,,}

    else

        loc_LogMsgInfo="$( date +%H:%M:%S ): Creating new ${loc_strDIR_Project,,} project directory."
        echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
        $loc_LogWriteCPro $loc_LogMsgInfo
    
        mkdir -p ${loc_strDIR_Project,,}
    
    fi

##add FTS Staff group
    loc_LogMsgInfo="$( date +%H:%M:%S ): Creating new staff group ${loc_strSta_SSH_GROUP_NAME,,}."
    echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
    $loc_LogWriteCPro $loc_LogMsgInfo

    groupadd ${loc_strSta_SSH_GROUP_NAME,,}
    loc_strStaGroupId="`cat "$loc_strFILE_GROUP" | grep $loc_strSta_SSH_GROUP_NAME | cut -d ':' -f3`"

##generate client account(s)
    loc_strCliGroupId="`cat "$loc_strFILE_GROUP" | grep $loc_strCli_SSH_GROUP_NAME | cut -d ':' -f3`"

##create client password file
    loc_LogMsgInfo="$( date +%H:%M:%S ): Generating client account file ${loc_strFILE_ProCliCsv,,}."
    echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
    $loc_LogWriteCPro $loc_LogMsgInfo

    echo "#CONFIDENTIAL! FTS ${loc_strProId,,} project client account and password information." >> ${loc_strFILE_ProCliCsv,,}
    echo "client_account:client_password" >> ${loc_strFILE_ProCliCsv,,}

    apg -m 10 -x 10 -n ${loc_numCliNumber} -M sncl -q >> ${tmp_strFILE_ProCliPasswd,,}

    c=1
    until [ $c -eq $((loc_numCliNumber+1)) ]
        do
            strLine=$c"p"
            cliNum=$((c+(${loc_numProNumber}*1000)))
            cliName=${loc_strProId,,}-c${cliNum: -3}
			
#if exists delete old account
            fn_delete_account ${loc_strProId,,} ${strDay,,} ${cliName,,}

            cliNote=${loc_strProId,,}
            cliPwd="`sed -n $strLine ${tmp_strFILE_ProCliPasswd,,}`"
            cliHome=${loc_strDIR_Project,,}/${cliName,,}

            if [ -d ${cliHome,,} ]; then

                loc_LogMsgInfo="$( date +%H:%M:%S ): Deleting old ${cliName,,} home dir ${cliHome,,}."
                echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
                $loc_LogWriteCPro $loc_LogMsgInfo

                rm -rf ${cliHome,,}

                loc_LogMsgInfo="$( date +%H:%M:%S ): Creating new ${cliName,,} home dir ${cliHome,,}."
                echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
                $loc_LogWriteCPro $loc_LogMsgInfo

                mkdir -p ${cliHome,,} ${cliHome,,}/${strDirUpload,,} ${cliHome,,}/${strDirDownload,,} ${cliHome,,}/${strDirSshKey,,}

            else

                loc_LogMsgInfo="$( date +%H:%M:%S ): Creating new ${cliName,,} home dir ${cliHome,,}."
                echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
                $loc_LogWriteCPro $loc_LogMsgInfo

                mkdir -p ${cliHome,,} ${cliHome,,}/${strDirUpload,,} ${cliHome,,}/${strDirDownload,,} ${cliHome,,}/${strDirSshKey,,}

            fi

            loc_LogMsgInfo="$( date +%H:%M:%S ): Creating new client account ${cliName,,}."
            echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
            $loc_LogWriteCPro $loc_LogMsgInfo

            echo "${cliName,,}:${cliPwd,,}:${cliNum,,}:${loc_strCli_SSH_GROUP_NAME,,}:${cliNote,,}:${cliHome,,}:${loc_strUsr_SHELL,,}" | newusers
            echo "${cliName,,}:${cliPwd,,}" >> ${loc_strFILE_ProCliCsv,,}

            chown ${cliName,,}:${loc_strStaGroupId,,} ${cliHome,,}/${strDirUpload,,}
            chmod 770 ${cliHome,,}/${strDirUpload,,}
            chown ${cliName,,}:${loc_strStaGroupId,,} ${cliHome,,}/${strDirDownload,,}
            chmod 570 ${cliHome,,}/${strDirDownload,,}
            chown ${cliName,,}:root ${cliHome,,}/${strDirSshKey,,}
            chmod 700 ${cliHome,,}/${strDirSshKey,,}

            loc_LogMsgInfo="$( date +%H:%M:%S ): Setting ${loc_numQtaSoftLimit}GB disk quota for ${cliName,,} account."
            echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
            $loc_LogWriteCPro $loc_LogMsgInfo

            xfs_quota -x -c "limit ${loc_strQtaLimits,,} ${cliName,,}" ${strDirHome,,}

            loc_LogMsgInfo="$( date +%H:%M:%S ): Created new ${cliName,,} client account."
            echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
            $loc_LogWriteCPro $loc_LogMsgInfo

            let "c += 1"

        done

##staff account
##generate staff account(s)
    loc_LogMsgInfo="$( date +%H:%M:%S ): Generating staff account file ${loc_strFILE_ProStaCsv,,}."
    echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
    $loc_LogWriteCPro $loc_LogMsgInfo

#create staff password file
    echo "CONFIDENTIAL! ${loc_strProId,,} - staff account and password information." > ${loc_strFILE_ProStaCsv,,}
    echo "staff_account:password" >> ${loc_strFILE_ProStaCsv,,}

    apg -m 10 -x 10 -n ${loc_numStaNumber} -M sncl -q >> ${tmp_strFILE_ProStaPasswd,,}

    c=1
    until [ $c -eq $((loc_numStaNumber+1)) ]
        do
            strLine=$c"p"
            staNum=$((c+(${loc_numProNumber}*1000+500000000)))
            staName=${loc_strProId,,}-s${staNum: -3}
			
#if exists delete old account
            fn_delete_account ${loc_strProId,,} ${strDay,,} ${staName,,}

            staNote=${loc_strProId,,}
            staPwd="`sed -n $strLine ${tmp_strFILE_ProStaPasswd,,}`"
            staHome=${loc_strDIR_Project,,}/${staName,,}

            if [ -d ${staHome,,} ]; then

                loc_LogMsgInfo="$( date +%H:%M:%S ): Deleting old ${staName,,} home dir ${staHome,,}."
                echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
                $loc_LogWriteCPro $loc_LogMsgInfo

                rm -rf ${staHome,,}

                loc_LogMsgInfo="$( date +%H:%M:%S ): Creating new ${staName,,} home dir ${staHome,,}."
                echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
                $loc_LogWriteCPro $loc_LogMsgInfo

                mkdir -p ${staHome,,} ${staHome,,}/${strDirUpload,,} ${staHome,,}/${strDirDownload,,} ${staHome,,}/${strDirSshKey,,}

            else

                loc_LogMsgInfo="$( date +%H:%M:%S ): Creating new ${staName,,} home dir ${staHome,,}."
                echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
                $loc_LogWriteCPro $loc_LogMsgInfo

                mkdir -p ${staHome,,} ${staHome,,}/${strDirUpload,,} ${staHome,,}/${strDirDownload,,} ${staHome,,}/${strDirSshKey,,}
            fi

            loc_LogMsgInfo="$( date +%H:%M:%S ): Creating new staff account ${staName,,}."
            echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
            $loc_LogWriteCPro $loc_LogMsgInfo

#            echo "${staName,,}:${staPwd,,}:${staNum,,}:${loc_strSta_SSH_GROUP_NAME,,}:${staNote,,}:${staHome,,}:${loc_strUsr_SHELL}" | newusers
            echo "${staName,,}:${staPwd,,}:${staNum,,}:${loc_strSta_SSH_GROUP_NAME,,}:${staNote,,}:${loc_strDIR_Project,,}:${loc_strUsr_SHELL}" | newusers
            echo "${staName,,}:${staPwd,,}" >> ${loc_strFILE_ProStaCsv,,}

#test access rights
            chown ${staName,,} ${staHome,,}
            chmod 570 ${staHome,,}
#test access rights

            chown ${staName,,} ${staHome,,}/${strDirUpload,,}
            chmod 770 ${staHome,,}/${strDirUpload,,}
            chown ${staName,,} ${staHome,,}/${strDirDownload,,}
            chmod 770 ${staHome,,}/${strDirDownload,,}
            chown ${staName,,}:root ${staHome,,}/${strDirSshKey,,}
            chmod 700 ${staHome,,}/${strDirSshKey,,}

            loc_LogMsgInfo="$( date +%H:%M:%S ): Setting ${loc_numQtaSoftLimit}GB disk quota for ${staName,,} account."
            echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
            $loc_LogWriteCPro $loc_LogMsgInfo

            xfs_quota -x -c "limit ${loc_strQtaLimits,,} ${staName,,}" ${strDirHome,,}

            loc_LogMsgInfo="$( date +%H:%M:%S ): Created new ${staName,,} account."
            echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
            $loc_LogWriteCPro $loc_LogMsgInfo

            let "c += 1"
        done

## delete client and staff tmp password files
    loc_LogMsgInfo="$( date +%H:%M:%S ): Deleting tmp file ${tmp_strFILE_ProCliPasswd,,}."
    echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
    $loc_LogWriteCPro $loc_LogMsgInfo

    rm -rf ${tmp_strFILE_ProCliPasswd,,}

    loc_LogMsgInfo="$( date +%H:%M:%S ): Deleting tmp file ${tmp_strFILE_ProStaPasswd,,}."
    echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
    $loc_LogWriteCPro $loc_LogMsgInfo

    rm -rf ${tmp_strFILE_ProStaPasswd,,}

##configure ssh service - /etc/ssh/sshd_config

    fn_conf_sshd ${loc_strProId,,} ${strDay,,} ${loc_strSta_SSH_GROUP_NAME,,}

##restart sshd service
    loc_LogMsgInfo="$( date +%H:%M:%S ): Restarting sshd daemon."
    echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
    $loc_LogWriteCPro $loc_LogMsgInfo

    service sshd restart

    loc_LogMsgInfo="$( date +%H:%M:%S ): New project ${loc_strProId} created."
    echo "$loc_LogMsgHeadCPro:$loc_LogMsgInfo" >> ${logFile,,}
    $loc_LogWriteCPro $loc_LogMsgInfo

}

    if [ ${numCliNumber} == "D" ]; then
   
        fn_check_par1 ${strProId,,}
        fn_delete_project $strProId $strDay 
 
    else
 
        fn_check_pars $strProId $numCliNumber $numStaNumber $numProQta
        fn_check_pro_dirs $strProId $strDirProjects $strDirProjectsInfo
        fn_delete_project $strProId $strDay
        fn_create_project $strProId $numCliNumber $numStaNumber $numProQta
    fi

exit 0
