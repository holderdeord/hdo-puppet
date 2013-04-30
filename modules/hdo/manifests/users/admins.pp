class hdo::users::admins {
  User <| tag == 'hdo-admin' |>
  Ssh_authorized_key <| tag == 'hdo-admin' |>
}
