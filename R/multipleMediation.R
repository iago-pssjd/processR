#' Make Mediation Equation with multiple X or multiple Y
#' @param X Names of independent variable
#' @param Y Names of dependent variable
#' @param M Names of mediator variable
#' @param labels optional list
#' @param data A data.frame
#' @param vars A list
#' @param moderator A list
#' @param covar A list of covariates
#' @param mode A numeric. 0: SEM equation, 1: regression equation
#' @param range A logical
#' @param rangemode range mode
#' @param serial logical If TRUE, serial variables are added
#' @param contrast integer If 2, absolute difference of contrasts are calculated
#'@param bmatrix integer specifying causal relations among mediators
#' @export
#' @examples
#' labels=list(X="cyl",M="am",Y="mpg")
#' covar=list(name=c("carb","disp"),site=list(c("M","Y"),"Y","Y"))
#' cat(multipleMediation(labels=labels,covar=covar,data=mtcars))
#' labels=list(X=c("cyl","wt"),M="am",Y="mpg")
#' moderator=list(name=c("vs"),site=list(c("a1","b1")))
#' cat(multipleMediation(labels=labels,data=mtcars))
#' cat(multipleMediation(labels=labels,moderator=moderator,data=mtcars))
#' labels=list(X="wt",M=c("cyl","am"),Y="mpg")
#' moderator=list(name=c("vs"),site=list(c("b1","b2")))
#' cat(multipleMediation(labels=labels,data=mtcars,range=FALSE))
#' cat(multipleMediation(labels=labels,moderator=moderator,data=mtcars,range=FALSE))
#' eq=multipleMediation(labels=labels,moderator=moderator,data=mtcars,range=FALSE,serial=FALSE,mode=1)
#' drawModel(equation=eq,labels=labels)
#' labels=list(X="X",M=c("M1","M2","M3"),Y="Y")
#' labels=list(X="X",M=c("M1","M2"),Y="Y")
#' cat(multipleMediation(labels=labels))
#' cat(multipleMediation(labels=labels,serial=TRUE))
#' moderator=list(name=c("W"),site=list(c("a1","b1")))
#' cat(multipleMediation(labels=labels,moderator=moderator,range=FALSE))
#' cat(multipleMediation(labels=labels,moderator=moderator,data=mtcars,range=FALSE))
#' cat(multipleMediation(X="am",Y="mpg",data=mtcars,moderator=moderator,covar=covar))
#' labels=list(X="cond",M=c("import","pmi"),Y="reaction")
#' cat(multipleMediation(labels=labels,data=pmi,serial=TRUE))
#' cat(multipleMediation(labels=labels,data=pmi,contrast=2))
#' cat(multipleMediation(labels=labels,data=pmi,mode=1,serial=TRUE))
#' labels=list(X="X",M=c("M1","M2","M3"),Y="Y")
#'cat(multipleMediation(labels=labels,bmatrix=c(1,1,1,1,1,1,1,1,1,1)))
#' labels=list(X="X",M=c("M1","M2"),Y="Y",W="W")
#'cat(multipleMediation(labels=labels,bmatrix=c(1,1,1,1,1,0)))
#'cat(multipleMediation(labels=labels,bmatrix=c(1,1,1,1,0,0)))
#' moderator=list(name=c("W"),matrix=list(c(1,1,0,1,0,0)))
#' eq=multipleMediation(labels=labels,moderator=moderator,bmatrix=c(1,1,1,1,1,1),mode=1)
#' drawModel(equation=eq,labels=labels,nodemode=2)
#' labels=list(X="X",M=c("M1","M2","M3"),Y="Y",W="W")
#' cat(multipleMediation(labels=labels,bmatrix=c(1,1,0,0,1,1,1,1,0,1)))
#'labels=list(X="X",M=c("M1","M2"),Y="Y")
#'cat(multipleMediation(labels=labels,serial=TRUE,mode=1))
#'vars=list(name=list(c("W","Z")),matrix=list(c(0,0,1,0,0,0)))
#'cat(multipleMediation(labels=labels,bmatrix=c(1,1,1,1,1,0),vars=vars))
multipleMediation=function(X=NULL,M=NULL,Y=NULL,labels=list(),data=NULL,
                           vars=list(),
                           moderator=list(),
                           covar=NULL,
                           mode=0,range=TRUE,rangemode=1,serial=FALSE,contrast=1,
                      bmatrix=NULL){

    # X=NULL;M=NULL;Y=NULL;labels=list();data=NULL
    # vars=list()
    # moderator=list()
    # covar=NULL
    # mode=0;range=TRUE;rangemode=1;serial=TRUE;contrast=1;
    # bmatrix=NULL
    # labels=list(X="X",M="M",Y="Y")
    # vars=list(name=list(c("W","Z")),site=list(c("a")))
    # moderator=list(name=c("V"),site=list(c("b")))
    # labels=list(X="cond",M=c("import","pmi"),Y="reaction")
    # vars=list()
    # moderator=list(name="gender",matrix=list(c(0,0,0,0,0,1)))
    # covar=list(name="age",site=list(c("M1","M2","Y")))



    if(is.null(X)) X=labels$X
    if(is.null(M)) if(!is.null(labels$M)) M=labels$M
    if(is.null(Y)) Y=labels$Y

    interactionNo=0
    res=c()

    xcount=length(X)
    if(!is.null(M)) {
        mcount=length(M)
    } else{
        mcount=0
    }
    ycount=length(Y)


    (XM=moderator$name[str_detect2(moderator$site,"a")])
    (MY=moderator$name[str_detect2(moderator$site,"b")])
    (XY=moderator$name[str_detect2(moderator$site,"c")])

    if(serial){
        if(mcount>1){
           if(is.null(bmatrix)) bmatrix=rep(1,sum(1:(mcount+1)))
        }
    } else{
        if(mcount>1){
            if(is.null(bmatrix)) bmatrix=parallelMatrix(mcount)
        }
    }

     # moderator=list(name=c("vs"),site=list(c("b1","b2")))
     # name="vs"
     # prefix="b"
    # moderator
    # name=MY
    # name
    # prefix="b"
    mod2pos=function(moderator,name,prefix){
        pos=list()
        pos1=c()
          # i=1
        for(i in seq_along(name)) {
            pos1=grep(name[i],moderator$name)
            pos1
            if(length(pos1)==1){
                temp=moderator$site[[pos1]]
                temp1=temp[str_detect(temp,prefix)]
                temp1
                res=str_extract(temp1,"[0-9]")
                res
                if(length(res)==1){
                    if(is.na(res)){
                       pos[[i]]=NULL
                    } else {
                       pos[[i]]=as.numeric(res)
                    }
                } else{
                    pos[[i]]=as.numeric(res)
                }
            }
        }
        pos
    }

    if(!is.null(M)){

        # moderator=list(name=c("W1","W2"),site=list(c("a1","b1"),"a1"))
        # moderator=list(name=c("W1","W2"),site=list(c("a"),"a1"))
        # name=c("W1","W2")
        # prefix="a"


        pos=mod2pos(moderator,name=XM,prefix="a")
        pos


        if(is.null(bmatrix)){
          eq1=makeCatEquation2(X=X,Y=M,W=XM,vars=vars,prefix="a",mode=mode,pos=pos,serial=serial,depy=FALSE,depx=TRUE)
        } else{
            # X
            # M
            # XM
            # mode
            # pos
            # bmatrix
            # vars
            # moderator
            # interactionNo
            eq1=makeCatEquation3(X=X,Y=M,W=XM,prefix="a",mode=mode,pos=pos,bmatrix=bmatrix,
                                 vars=vars,moderator=moderator,depy=FALSE,depx=TRUE,
                                 interactionNo=interactionNo)
        }
        eq1
        # maxylev

        interactionNo=str_count(eq1,"interaction")
        #
        covar
        if(!is.null(covar)){
            if(length(M)==1){
                covar$site=lapply(covar$site,function(x) str_replace(x,"Mi|M",M))
            } else{
                for(i in 1:length(M)){
                   covar$site=lapply(covar$site,function(x) str_replace(x,paste0("M",i),M[i]))
                }
            }
            if(mode){
                eq1=addCovarEquation(eq1,covar,prefix=NULL)
            } else{
                eq1=addCovarEquation(eq1,covar,prefix="f",multipleMediator = ifelse(length(M)==1,FALSE,TRUE))
            }
        }
        eq1
        if(mode==1) eq1=checkEquationVars(eq1)

        temp1=unlist(strsplit(eq1,"\n"))
        temp1=lapply(1:length(temp1),function(i){
            unlist(strsplit(unlist(strsplit(temp1[i],"~",fixed=TRUE))[2],"+",fixed=TRUE))
        })
        temp1


        # moderator
        # MY
        pos=mod2pos(moderator,name=MY,prefix="b")
        pos

        if(is.null(bmatrix)){
          eq2=makeCatEquation2(X=M,Y=Y,W=MY,prefix="b",vars=vars,mode=mode,pos=pos,depy=TRUE,depx=FALSE)
        } else{
            eq2=makeCatEquation3(X=M,Y=Y,W=MY,prefix="b",mode=mode,pos=pos,bmatrix=bmatrix,
                                 vars=vars,moderator=moderator,depy=TRUE,
                                 interactionNo=interactionNo)
            interactionNo=interactionNo+str_count(eq2,"interaction")
        }
          # eq2
         # M
         # Y
         # MY
         # pos
        # bmatrix
        temp2=unlist(strsplit(eq2,"~"))[2]
        temp2=unlist(strsplit(temp2,"+",fixed=TRUE))
        temp2
    }

    (pos=mod2pos(moderator,name=XY,prefix="c"))
    if(is.null(bmatrix)){
    eq3=makeCatEquation2(X=X,Y=Y,W=XY,vars=vars,prefix="c",mode=mode,pos=pos,serial=serial,depy=TRUE,depx=TRUE)
    } else{
        eq3=makeCatEquation3(X=X,Y=Y,W=XY,prefix="c",mode=mode,pos=pos,bmatrix=bmatrix,
                             vars=vars,moderator=moderator,depy=TRUE,depx=TRUE,
                             interactionNo=interactionNo)
    }
       eq3
     # bmatrix
    if(str_detect(eq3,"~")){
    temp3=unlist(strsplit(eq3,"~"))[2]
    temp3
    temp3=unlist(strsplit(temp3,"+",fixed=TRUE))
    } else{
        temp3=""
    }

    if(is.null(M)) {
        eq=eq3
    } else{
        if(eq3!="") {
            if(eq2=="") {
               eq=eq3
            } else{
               eq=sumEquation(eq2,eq3)
            }
        } else{
            eq=eq2
        }
    }
    eq
    if(!is.null(covar)){
        covar$site=lapply(covar$site,function(x) str_replace(x,"Y",Y))
        if(mode){
            eq=addCovarEquation(eq,covar,prefix=NULL,grouplabels=NULL)
        } else{
            eq=addCovarEquation(eq,covar,prefix="g",grouplabels=NULL)
        }
    }

    equation=ifelse(is.null(M),eq,paste(eq1,eq,sep="\n"))
    equation


    if((mode==0)&(!is.null(M))){
        moderatorNames=moderator$name
        for(i in seq_along(moderatorNames)){
            name=moderatorNames[i]
            temp=paste0(name," ~ ",name,".mean*1\n")
            temp=paste0(temp,name," ~~ ",name,".var*",name,"\n")
            equation=paste0(equation,"\n",temp)
        }
        temp1
        temp3
        moderatorNames
        range
        rangemode

        if(!is.na(temp2[1])){
        temp=makeIndirectEquationCat2(X,M,temp1,temp2,temp3,moderatorNames,range=range,
                                      data=data,rangemode=rangemode,serial=serial,contrast=contrast)
        temp
        equation=paste0(equation,temp)
        }
    }

    if(mode==0) equation=deleteSingleNumber(equation)
    equation


}

#' Make bmatrix for parallel multiple mediator model
#' @param n integer number of mediator
#' @export
#' @examples
#' parallelMatrix(3)
parallelMatrix=function(n=2){
    res=c(1)
    for(i in 1:n){
        if(i==n) {
            res=c(res,1,rep(1,i))
        } else{
            res=c(res,1,rep(0,i))
        }
    }
    res
}

#'Make indirect equation for categorical variables
#'@param X A character vector
#'@param M A character vector
#'@param temp1 A character vector
#'@param temp2 A character vector
#'@param temp3 A character vector
#'@param moderatorNames A character vector
#'@param range A logical
#' @param data A data.frame
#' @param rangemode range mode
#' @param probs numeric vector of probabilities with values in [0,1]
#' @param serial logical If TRUE, serial variables are added
#' @param contrast integer If 2, absolute difference of contrasts are calculated
#'@export
makeIndirectEquationCat2=function(X,M,temp1,temp2,temp3,moderatorNames,
                                 range=TRUE,data=NULL,rangemode=1,probs=c(0.16,0.5,0.84),serial=FALSE,contrast=1){

    # data=mtcars;range=FALSE;rangemode=1;probs=c(0.16,0.5,0.84);serial=TRUE
    # cat("\nX=",X)
    # cat("\nM=",M)
    # cat("\nstr(temp1)\n")
    # str(temp1)
    # cat("\nstr(temp2)\n")
    # str(temp2)
    # cat("\nstr(temp3)\n")
    # str(temp3)
    # cat("\nmoderatorNames=",moderatorNames)

    equation=""

    groups=list()

    # if(length(grouplabels)>0){
    #
    #     count=unlist(lapply(1:length(grouplabels),function(i){
    #         length(unique(data[[names(grouplabels)[i]]]))-1
    #     }))
    #
    #     for(i in seq_along(grouplabels)){
    #         groups[[names(grouplabels)[i]]]=paste0(grouplabels[[i]],1:count[i])
    #     }
    # }
    #
    # if(X %in% names(groups)) X=groups[[X]]
    # if(M %in% names(groups)) M=groups[[M]]
    xcount=length(X)
    mcount=length(M)

    indirectT<-directT<-c()
    equation=paste0(equation,"\n\n# Indirect Effect(s)\n")
    for(i in 1:xcount){
        for(j in 1:mcount){

              # i=1;j=2
            xlabel=ifelse(xcount>1,paste0(".",X[i]),"")
            mlabel=ifelse(mcount>1,paste0(".",M[j]),"")
            xmlabel=(i-1)*mcount+j
            temp4<-temp1[[j]]

            temp4=stringr::str_replace_all(temp4,":","*")
            ind1=strGrouping(temp4,X[i])$yes
            ind1
            if(length(ind1)==0) next
            temp2=stringr::str_replace_all(temp2,":","*")
            ind2=strGrouping(temp2,M[j])$yes
            ind2
            if(length(ind2)==0) next
            ind=paste0("(",str_flatten(ind1,"+"), ")*(",str_flatten(ind2,"+"),")")
            ind
            res=treatModerator(ind,moderatorNames,data=data,rangemode=rangemode,probs=probs)
            res
            ind<-res[[1]]
            ind.below=res[[2]]
            ind.above=res[[3]]
            equation=paste0(equation,"\nindirect",xmlabel," := ",ind)
            indirectT=c(indirectT,paste0("indirect",xmlabel))
            if(!is.null(extractIMM(ind))) {
                equation=paste0(equation,"\nindex.mod.med",xmlabel," :=",extractIMM(ind),"\n")
            }
            temp3=stringr::str_replace_all(temp3,":","*")
            direct=strGrouping(temp3,X[i])$yes
            dir=paste0(str_flatten(direct,"+"))
            res=treatModerator(dir,moderatorNames,data=data,rangemode=rangemode,probs=probs)
            dir<-res[[1]]
            dir.below=res[[2]]
            dir.above=res[[3]]
            equation=paste0(equation,"\ndirect",xmlabel," :=",dir)
            directT=c(directT,dir)
            # equation=paste0(equation,"total",xmlabel," := direct",xlabel,mlabel," + indirect",xlabel,mlabel,"\n")
            # equation=paste0(equation,"prop.mediated",xmlabel," := indirect",xlabel,mlabel," / total",xlabel,mlabel,"\n")
            if((range)&(length(moderatorNames)>0)){
                equation=paste0(equation,"\nindirect",xmlabel,".below :=",ind.below,"\n")
                equation=paste0(equation,"indirect",xmlabel,".above :=",ind.above,"\n")
                equation=paste0(equation,"direct",xmlabel,".below:=",dir.below,"\n")
                equation=paste0(equation,"direct",xmlabel,".above:=",dir.above,"\n")
                equation=paste0(equation,"total",xmlabel,".below := direct",xmlabel,".below + indirect",xmlabel,".below\n",
                                "total",xmlabel,".above := direct",xmlabel,".above + indirect",xmlabel,".above\n")
                equation=paste0(equation,"prop.mediated",xmlabel,".below := indirect",xmlabel,".below / total",xmlabel,".below\n",
                                "prop.mediated",xmlabel,".above := indirect",xmlabel,".above / total",xmlabel,".above\n")
                equation
                # if(length(moderatorNames)==1) {
                #
                #     temp=ind1[str_detect(ind1,fixed("*"))]
                #     temp=unlist(str_split(temp,fixed("*")))
                #     temp
                #     if(length(temp)>2){
                #         temp[seq(1,length(temp),2)]
                #         ind2
                #         equation=paste0(equation,"index.mod.med",xlabel,mlabel," := ",
                #                         temp[seq(1,length(temp),2)],"*",str_flatten(ind2,"+"),"\n")
                #     }
                #
                # }
            }
        }
    }

    indcount=xcount*mcount
    if(serial){
        equation=paste0(equation,"\n\n# Secondary Indirect Effect(s)\n")
        secondIndirect=get2ndIndirect(X=X,M=M)
        indcount=indcount+length(secondIndirect)
        for(k in 1:length(secondIndirect)){
            equation=paste0(equation,"\nindirect",paste0(k+xcount*mcount),":= ",secondIndirect[k])
        }
        indirectT=c(indirectT,secondIndirect)
    }
    if(length(indirectT)>1){
        equation=paste0(equation,"\n\n# Specific Indirect Effect Contrast(s)\n")
        res=combn(indirectT,2)
        for(i in 1:ncol(res)){
            if(contrast==2){
               equation=paste0(equation,"\nContrast",i," := abs(",res[1,i],")-abs(",res[2,i],")")
            } else {
                equation=paste0(equation,"\nContrast",i," := ",res[1,i],"-",res[2,i])
            }
        }
    }

    equation=paste0(equation,"\n\n# Indirect/Direct/Total Effect(s)\n")
    indirectT=paste0(indirectT,collapse="+")
    equation=paste0(equation,"\nindirect := ",indirectT)
    directT=unique(directT)
    directT=paste0(directT,collapse="+")
    if(directT==""){
        equation=paste0(equation,"\n# There is no direct effect in this model\n")
    } else{
    equation=paste0(equation,"\ndirect := ",directT)
    equation=paste0(equation,"\ntotal := indirect + direct")
    equation=paste0(equation,"\nprop.mediated := indirect / total\n")
    }

    equation
}

#' get2ndIndirect effect
#' @param X Names of independent variable
#' @param M Names of mediator variable
#' @param Y Names of dependent variable
#' @param labels A list
#' @export
#' @examples
#' get2ndIndirect(X="X",M=c("M1","M2","M3"))
get2ndIndirect=function(X=NULL,M=NULL,Y=NULL,labels=list()){


     # X=NULL;M=NULL;Y=NULL;labels=list()
    # X="X";M=c("M1","M2","M3")
    if(is.null(X))  X=labels$X
    if(is.null(Y))  Y=labels$Y
    if(is.null(M)) if(!is.null(labels$M)) M=labels$M
    if(is.null(Y)) if(!is.null(labels$Y)) Y=labels$Y

    (xcount=length(X))
    if(is.null(Y)) {
        ycount=1
    } else ycount=length(Y)
    (mcount=length(M))

    result=c()
    for(i in 1:xcount){
        for(j in 1:ycount){
            if(mcount>1){
                for(k in 2:mcount){
                    res=combn(1:mcount,k)
                    for(l in 1:ncol(res)){
                        temp1=c()
                        for(m in 2:nrow(res)){
                            temp2=paste0("d",res[m,l],res[m-1,l])
                            temp1=c(temp1,temp2)
                        }
                        temp1=paste0(temp1,collapse="*")
                        temp=paste0("a",ifelse(xcount==1,"",i),res[1,l],"*",temp1,
                                    "*b",ifelse(ycount==1,"",j),res[nrow(res),l])
                        result=c(result,temp)
                    }
                }
            }
        }
    }

    result
}


#' Check dependent variables in equations
#' @param equation A string of regression formula
#' @importFrom stringr str_replace_all
#' @export
#' @examples
#' equation="M1~X*M*W+W*Z\nM2~X+M1+X"
#' checkEquationVars(equation)
checkEquationVars=function(equation){
     equations=unlist(strsplit(equation,"\n"))
     equations
     res=sapply(equations,checkEqVars)
     paste0(res,collapse="\n")

}

#' Check dependent variables in a equation
#' @param eq A string of regression formula
#' @importFrom stringr str_replace_all
#' @export
#' @examples
#' eq="M2~X+M+X+X*M*W"
#' checkEqVars(eq)
#' eq="Y~M+W+M:W+X+W+X:W"
#' checkEqVars(eq)
checkEqVars=function(eq){
    eq=stringr::str_replace_all(eq," ","")
    res=unlist(strsplit(eq,"~"))
    dep=res[1]
    temp=unlist(strsplit(res[2],"\\+"))
    temp
    res=unlist(sapply(temp,treatInteraction))
    res
    res=unique(res)
    if(sum(str_detect(res,":"))>=2){
        temp=res[str_detect(res,":")]
        res1=unlist(strsplit(temp,":"))
        dup=res1[duplicated(res1)]
        if(length(dup)==1){
            res=c(setdiff(res[!str_detect(res,":")],dup),dup,res[str_detect(res,":")])
        }
    }
    paste0(dep,"~",paste0(res,collapse="+"))
}

require(stringr)

#' unfold interaction
#' @param var name of variables
#' @importFrom stringr str_detect
#' @importFrom utils combn
#' @export
#' @examples
#' var="X*M"
#' treatInteraction(var)
#' var="X*M*W"
#' treatInteraction(var)
treatInteraction=function(var){
    if(str_detect(var,"\\*")){
        temp=unlist(strsplit(var,"\\*"))
        count=length(temp)
        res=c()
        i=1
        for(i in 1:count){
            res1=combn(temp,i)
            for(j in 1:ncol(res1)){
                 res=c(res,paste0(res1[,j],collapse=":"))
            }
        }
        res
    } else{
        res=var
    }
    res
}

