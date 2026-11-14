
## tidy the sacle data for other functions
tidy_scale <- function(data){
    scale <- filter(data, is.na(demographic)) |>
        select(-c(choices, required, demographic))
    dat_simple <- scale |>
        mutate(label = factor(label,
                              levels = unique(c(scale$label))),
               q_num = 1:nrow(scale))
    return(dat_simple)
}

## return a fixed order for all participants
fix_template <- function(data, n_subj){
    df_fx <- data.frame(matrix(nrow = 1,
                               ncol = max(data$q_num)
                               ))
    colnames(df_fx) <- paste0("p", 1:max(data$q_num))
    df_fx[1, ] <- data$q_num
    df_fx <- df_fx |>
        mutate(order_label = "fx")
    return(df_fx)
}

## Randomize item sequences for all participants
random_template <- function(data, n_subj){
    rand_ls <- lapply(1:n_subj, \(.x) sample(data$q_num))
    df_rd <- do.call(rbind, rand_ls) |> as.data.frame()
    colnames(df_rd) <- paste0("p", 1:max(data$q_num))
    df_rd <- df_rd |>
        mutate(order_label = paste0("rd", 1:n_subj))
    return(df_rd)
}

## Method to generate a Latin-Square, regardless item factor
latin_template <- function(data, n_subj){
    n <- max(data$q_num)
    lat_sq <- array (rep (seq_len (n), each = n), c (n, n))
    lat_sq <- apply (lat_sq - 1, 2, function (x) (x + 0:(n-1)) 
                     %% n) + 1
    ls_df <- as.data.frame(lat_sq)
    colnames(ls_df) <- paste0("p", 1:n)
    ls_df <- ls_df |>
        mutate(order_label = paste0("ls", 1:n))
    return(ls_df)
}

## methods to implement PSR (maximal subblocks) for all participants
psr_template <- function(data, n_subj){
    fac_stats <- count(data, label)
    n_fac <- nrow(fac_stats)
    nr <- unique(fac_stats$n)
    if(length(nr) > 1) {
        stop("Currently, PSR is available only when Nrs are equal")
    } else {
        n_subblock <- nth(explan::possible_subblocks(nr), -1)
    }
    ## ------
    psr_df <- lapply(1:n_subj, \(.x) {
        psr_once <- array(NA, nrow(data))
        f_order <- explan::psr(fac_stats$label, n_subblock, nr)
        for(.y in fac_stats$label){
            psr_once[which(f_order == .y)] <- sample(filter(data, label == .y)$q_num)
        }
        return(psr_once)}
        )
    psr_df <- do.call(rbind, psr_df) |> as.data.frame()
    colnames(psr_df) <- paste0("p", 1:max(data$q_num))
    psr_df <- psr_df |>
        mutate(order_label = paste0("psrmax", 1:n_subj))
    return(psr_df)
}

## binding items under the same factor
grouping_template <- function(data,
                              ## turn on to randomize factor order in a sequence independently
                              random_factor = FALSE,
                              ## turn on to randomize item order within factors
                              random_item = FALSE,
                              n_subj){
    fac_stats <- count(data, label)
    n_fac <- nrow(fac_stats)
    nr <- unique(fac_stats$n)
    items <- data$q_num
    names(items) <- data$label
    subgroup <- factor(fac_stats$label)
    item_groups <- split(items, subgroup)
    
    if(random_factor == FALSE) {
        if(random_item == FALSE) {
            ## ------ fix group order, fix item order ------
            order_label <- "gff"
            group_ff <- unlist(item_groups) |> unname()
            group_df <- group_ff |> t() |> as.data.frame()
        } else {
            ## ------ fix group order, random item order ------
            order_label <- paste0("gfr", 1:n_subj)
            group_fr <- lapply(1:n_subj, \(.x) {
                lapply(item_groups, sample) |>
                    unlist() |> unname()
            })
            group_df <- do.call(rbind, group_fr) |>
                as.data.frame()
        }
    } else {
        if(random_item == FALSE) {
            ## ------ random group order, fix item order ------
            order_label <- paste0("grf", 1:n_subj)
            group_rf <- lapply(1:n_subj, \(.x) {
                sample(item_groups) |>
                    unlist() |> unname()
            })
            group_df <- do.call(rbind, group_rf) |>
                as.data.frame()
        } else {
            ## ------ random group order, random item order ------
            order_label <- paste0("grr", 1:n_subj)
            group_rr <- lapply(1:n_subj, \(.x) {
                sample(lapply(item_groups, sample)) |>
                    unlist() |> unname()
            })
            group_df <- do.call(rbind, group_rr) |>
                as.data.frame()
        }
    }
    colnames(group_df) <- paste0("p", 1:max(data$q_num))
    group_df <- group_df |>
        mutate(order_label = order_label)
    return(group_df)
}

## cycling items through given factor orders
cycle_template <- function(data,
                    ## turn on to randomize factor order in a sequence
                    random_factor = FALSE,
                    ## turn on to randomize assign items in cycles
                    random_item = FALSE,
                    n_subj){
    fac_stats <- count(data, label)
    n_fac <- length(fac_stats$n)
    items <- array(data$q_num)
    names(items) <- data$label
    nr <- nrow(data)/n_fac
    subgroup <- factor(fac_stats$label)
    item_groups <- split(items, subgroup)
    
    if(random_factor == FALSE) {
        ## ------ fix cycle order, fix item order ------
        if(random_item == FALSE) {
            order_label <- "cff"
            cycle_ff <- lapply(1:nr, \(.x){
                lapply(item_groups, \(.y) .y[.x]) |>
                    unlist() |> unname()
            }) |> unlist()
            cycle_df <- cycle_ff |>
                t() |> as.data.frame()
        } else {
            ## ------ fix cycle order, random item order ------
            order_label <- paste0("cfr", 1:n_subj)
            cycle_fr <- lapply(1:n_subj, \(.x) {
                rand_item <- lapply(item_groups, sample) 
                do_once <- lapply(1:nr, \(.y){
                    lapply(rand_item, \(.z) .z[.y]) |>
                        unlist() |> unname()
                }) |> unlist()
                return(do_once)
            })
            cycle_df <- do.call(rbind, cycle_fr) |> as.data.frame()
        }
    } else {
        ## ------ random cycle order, fix item order ------
        if(random_item == FALSE) {
            order_label <- paste0("crf", 1:n_subj)
            cycle_rf <- lapply(1:n_subj, \(.x) {
                lapply(1:nr, \(.y){
                    lapply(sample(item_groups), \(.z) .z[.y]) |>
                        unlist() |> unname()
                }) |> unlist()
            })
            cycle_df <- do.call(rbind, cycle_rf) |> as.data.frame()
        } else {
            ## ------ random cycle order, random item order ------
            order_label <- paste0("crr", 1:n_subj)
            cycle_rr <- lapply(1:n_subj, \(.x) {
                rand_item <- sample(lapply(item_groups, sample))
                do_once <- lapply(1:nr, \(.y){
                    lapply(rand_item, \(.z) .z[.y]) |>
                        unlist() |> unname()
                }) |> unlist()
                return(do_once)
            })
            cycle_df <- do.call(rbind, cycle_rr) |> as.data.frame()
        }
    }
    colnames(cycle_df) <- paste0("p", 1:max(data$q_num))
    cycle_df <- cycle_df |>
        mutate(order_label = order_label)
    return(cycle_df)
}

generate_plan <- function(data, plan_ls, subj_ls, seed = 1){
    if(is.null(seed)){
        stop("A random seed is necessary for reproducible randomization.")
    } else {
        set.seed(seed)
    }
    plan_df <- as.data.frame(matrix(nrow = 0, ncol = (max(data$q_num)+1)))
    colnames(plan_df) <- c(paste0("p", 1:max(data$q_num)), "order_label")
    if ("Fixed order" %in% plan_ls){
        df_fx <- fix_template(data, subj_ls["fx"])
        plan_df <- rbind(plan_df, df_fx)
    }
    if ("Simple randomization" %in% plan_ls){
        df_rd <- random_template(data, subj_ls["rd"])
        plan_df <- rbind(plan_df, df_rd)
    }
    if ("Latin Square" %in% plan_ls){
        df_ls <- latin_template(data, subj_ls["ls"])
        plan_df <- rbind(plan_df, df_ls)
    }
    if ("Permuted-Subblock Randomization (PSR)" %in% plan_ls){
        df_psr <- psr_template(data, subj_ls["psr"])
        plan_df <- rbind(plan_df, df_psr)
    }
    if ("Fixed Grouping" %in% plan_ls){
        df_group_ff <- grouping_template(data,
                                         random_factor = FALSE,
                                         random_item = FALSE,
                                         subj_ls["gff"])
        plan_df <- rbind(plan_df, df_group_ff)
    }
    if ("Random Grouping - factor" %in% plan_ls){
        df_group_rf <- grouping_template(data,
                                         random_factor = TRUE,
                                         random_item = FALSE,
                                         subj_ls["grf"])
        plan_df <- rbind(plan_df, df_group_rf)
    }
    if ("Random Grouping - item" %in% plan_ls){
        df_group_fr <- grouping_template(data,
                                         random_factor = FALSE,
                                         random_item = TRUE,
                                         subj_ls["gfr"])
        plan_df <- rbind(plan_df, df_group_fr)
    }
    if ("Random Grouping - both" %in% plan_ls){
        df_group_rr <- grouping_template(data,
                                         random_factor = TRUE,
                                         random_item = TRUE,
                                         subj_ls["grr"])
        plan_df <- rbind(plan_df, df_group_rr)
    }
    if ("Fixed Cycling" %in% plan_ls){
        df_cycle_ff <- cycle_template(data,
                                      random_factor = FALSE,
                                      random_item = FALSE,
                                      subj_ls["cff"])
        plan_df <- rbind(plan_df, df_cycle_ff)
    }
    if ("Random Cycling - factor" %in% plan_ls){
        df_cycle_rf <- cycle_template(data,
                                      random_factor = TRUE,
                                      random_item = FALSE,
                                      subj_ls["crf"])
        plan_df <- rbind(plan_df, df_cycle_rf)
    }
    if ("Random Cycling - item" %in% plan_ls){
        df_cycle_fr <- cycle_template(data,
                                      random_factor = FALSE,
                                      random_item = TRUE,
                                      subj_ls["cfr"])
        plan_df <- rbind(plan_df, df_cycle_fr)
    }
    if ("Random Cycling - both" %in% plan_ls){
        df_cycle_rr <- cycle_template(data,
                                      random_factor = TRUE,
                                      random_item = TRUE,
                                      subj_ls["crr"])
        plan_df <- rbind(plan_df, df_cycle_rr)
    }

    plan_df <- plan_df |>
        mutate(dplyr::across(where(is.double), as.integer))
    plan_df <- plan_df[, c("order_label", paste0("p", 1:(ncol(plan_df) - 1)))]
    rownames(plan_df) <- 1:nrow(plan_df)
    return(plan_df)
}

## generate order_subj plan for dynamic PHP query
plan_subj <- function(plan, subj_ls){
    n <- array(NA, length(plan$order_label))
    names(n) <- plan$order_label
    n[na.omit(match(names(subj_ls), names(n)))] <- subj_ls[na.omit(match(names(n), names(subj_ls)))]
    data_plan <- data.frame(order_label = plan$order_label) |>
        mutate(
            n = ifelse(is.na(n), 1, n)
    ) |>
        mutate(dplyr::across(where(is.double), as.integer))
    return(data_plan)
}
