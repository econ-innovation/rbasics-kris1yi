# process_aminer.R

#  在命令里面输入下面的代码即可调用该文件，其中“”为论文数据文件所在的地址。
# Rscript process_aminer.R "D:/ZY_r_data/1R_cause/R_eco_learn/data/assignment_idaccuracy/Aminer/"


library(purrr)  # 加载 purrr 包以使用函数式编程
library(readr)  # 加载 readr 包以使用 read_csv 函数
library(dplyr)  # 加载 dplyr 包以使用数据框操作
library(parallel)  # 加载 parallel 包以使用并行计算

# 从命令行接收路径参数
args <- commandArgs(trailingOnly = TRUE)

# 提取传递的路径参数
folder_path <- args[1]

# 获取 CSV 文件列表
file_list <- list.files(folder_path, pattern = "\\.csv$", full.names = TRUE)

# 如果有文件，则进行数据合并和标题一致性检查
if (length(file_list) > 0) {
  # 读取第一个文件的标题
  first_file_data <- read_csv(file_list[1], col_types = cols())
  first_file_title <- names(first_file_data)
  
  # 逐个检查每个文件的标题是否与第一个文件一致
  titles_consistent <- all(mclapply(file_list, function(file) {
    current_data <- read_csv(file, col_types = cols())
    current_title <- names(current_data)
    identical(first_file_title, current_title)
  }, mc.preschedule = FALSE))
  
  if (titles_consistent) {
    # 使用 lapply 读取并合并所有文件
    combined_data <- bind_rows(mclapply(file_list, function(file) {
      read_csv(file, col_types = cols()) %>%
        select(doi, 标题, 期刊, 年份, 作者)  # 选择感兴趣的列
    }, mc.preschedule = FALSE))
    
    # 显示合并后的数据
    print(combined_data)
    
    # 将合并后的数据保存为一个新的 CSV 文件
    output_file <- paste0(folder_path, "/combined_data.csv")
    write.csv(combined_data, file = output_file, row.names = FALSE)
    cat("合并后的数据已保存为", output_file, "\n")
  } else {
    cat("每个 CSV 文件的标题不一致.\n")
  }
} else {
  cat("未找到任何 CSV 文件.\n")
}
