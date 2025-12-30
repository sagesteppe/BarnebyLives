#!/bin/bash

# Render README.rmd to README.md
Rscript -e 'rmarkdown::render("README.rmd", encoding="UTF8")'

echo "README updated successfully!"
