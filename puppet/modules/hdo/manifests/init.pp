#
# Further classes are defined into hdo/{class}.pp
# for example hdo/backend.pp and hdo/database.pp
# and you can include them with:
#
# include hdo::backend
# include hdo::database
#
# Basically this is an empty container
# used only to access templates at this stage.
# So it's possible to say "template('hdo/something.erb')"
# from other hdo::* classes
#

class hdo {

  include hdo::common

}
