scaffold_dir := $(dir $(MAKEFILE_LIST))
include $(scaffold_dir)variables.mk
include $(scaffold_dir)attributes.mk
include $(scaffold_dir)commands.mk
include $(scaffold_dir)module-helper.mk
include $(scaffold_dir)modules.mk

# This target is just a stand in so that make does not complain about
# not knowing how to make a specific target
%.mk: ;

# include the makefile to get its targets
include $(MAKECMDGOALS)

# print out what process_module_targets would have done
$(info $(call process_module_targets,$(MAKECMDGOALS)))
