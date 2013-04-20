name "base"
description "Base server config - EmpireOne Group"

# List of recipes and roles to apply.
run_list(

	# The omnibus updater when enabled will automatically update chef-solo to the latest version
	# "recipe[omnibus_updater]",

	# Sets the default timezone for the server (see default_attributes)
	"recipe[timezone-ii]"

)

# List of recipes for a given environment
# env_run_lists "prod" => [], "ci" => [], "dev" => [], "local" => []


# Attributes applied if the node doesn't have it set already.
default_attributes( 
	"tz" => "Australia/Sydney"
)

# Attributes applied no matter what the node specifies.
override_attributes "node" => { "attribute" => [ "value", "value", "etc." ] }
