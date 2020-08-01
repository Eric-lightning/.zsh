d() {
  if [[ "$1" ==  "sh" || "$1" == "show" ]]
  then
    shift
    case "$2" in
      "pr" || "pro" || "projects" )
        dstask show-projects ;;
      "ta" || "tags" )
        dstask show-tags ;;
      "ac" || "now" )
        dstask show-active ;;
      "pa" || "stopped" )
        dstask show-paused ;;
      "op")
        dstask show-open ;;
      "re" || "resolved" )
        dstask show-resolved ;;
      "un" || "unorganised" || "untagged" || "unproj" || "unprojects" )
        dstask show-unorganised ;;
    esac
  else
    dstask "$@"
  fi
}
