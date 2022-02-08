
# Packages ----------------------------------------------------------------

library(bookdown)
library(knitr)
library(tictoc)

# Clean files -------------------------------------------------------------

options(bookdown.clean_book = TRUE)
bookdown::clean_book()
rmarkdown::clean_site(preview = FALSE)

# Update ecodados
# remotes::install_github(repo = "paternogbc/ecodados", force = TRUE)

# Render html -------------------------------------------------------------
tic()
rmarkdown::render_site(output_format = 'bookdown::gitbook', encoding = 'UTF-8')
toc()

# Render pdf
tic()
rmarkdown::render_site(output_format = 'bookdown::pdf_document2', encoding = 'UTF-8')
toc()

# Render word
tic()
rmarkdown::render_site(output_format = 'bookdown::word_document2', encoding = 'UTF-8')
toc()

# end ---------------------------------------------------------------------
