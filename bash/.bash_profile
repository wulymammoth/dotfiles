for file in ~/.{exports,exports_local,bashrc,profile,aliases,aliases_work,functions,functions_work,utilities}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
