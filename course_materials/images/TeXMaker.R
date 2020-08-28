library(tidyverse)

dirName <- list.files() %>% 
    as_tibble %>% 
    dplyr::filter(str_detect(.$value,"text"))

gwd <- getwd()

for(l in 1:11){
    setwd(dirName$value[l])
    FN <- list.files() %>% as_tibble %>% 
        dplyr::mutate(section = str_split_fixed(.$value,pattern = "\\.",3)[,1]) %>% 
        rowid_to_column("NO") %>% 
        dplyr::filter(str_detect(.$value,pattern = "png")) %>% 
        dplyr::mutate(label = paste0("fig::",.$section,"_",NO)) %>%
        group_by(section) %>% 
        nest() %>% print
    
    ### TeXファイルを開く
    openFN <- paste0(gwd,"/",dirName$value[l],".tex")
    ### プリアブルを書く
    cat(file=openFN,"\\documentclass[uplatex]{jsreport}","\n")
    cat(file=openFN,"\\usepackage{docmute}","\n",append = T)
    cat(file=openFN,"\\usepackage{myStyle}","\n",append = T)
    word = paste0("\\label{chapter",l,"}")
    cat(file=openFN,word,"\n",append = T)
    cat(file=openFN,"\\begin{document}","\n",append = T)
    word = paste0("\\chapter{第",l,"講}")
    cat(file=openFN,word,"\n",append = T)
    
    ### セクションごとに図を挿入していく
    for(SEC in 1:NROW(FN)){
        word = "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
        cat(file=openFN,word,"\n",append = T)
        word = "\\clearpage"
        cat(file=openFN,word,"\n",append = T)
        word = paste0("\\section{資料",LETTERS[SEC],"}")
        cat(file=openFN,word,"\n",append = T)
        word = paste0("\\label{sec::",l,letters[SEC],"}")
        cat(file=openFN,word,"\n",append = T)
        tmp <- FN$data[[SEC]]
        for(FIGS in 1:NROW(tmp)){
            ##図の挿入
            word = paste0("\t\\begin{figure}[ht]")
            cat(file=openFN,word,"\n",append = T)
            word = paste0("\t\t\\centering")
            cat(file=openFN,word,"\n",append = T)
            word = paste0("\t\t\\includegraphics[keepaspectratio,height=12cm]{images/",dirName$value[l],"/",tmp$value[FIGS],"}")
            cat(file=openFN,word,"\n",append = T)
            word = paste0("\t\t\\label{",tmp$label[FIGS],"}")
            cat(file=openFN,word,"\n",append = T)
            word = paste0("\t\\end{figure}")
            cat(file=openFN,word,"\n",append = T,"\n\n")
        }
    }
    # 一つ上の階層に戻って次のファイルへ
    cat(file=openFN,"\\end{document}","\n",append = T)
    setwd(gwd)
}
