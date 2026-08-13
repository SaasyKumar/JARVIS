STORAGE=$(df -h / | awk 'NR==2 {
    printf "%s available of %s(%s free)", $4, $2, $5
}')