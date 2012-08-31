class hdo::backend::nginx inherits hdo::backend {
  include hdo::nginx
  include hdo::unicorn
}