#run {
    Compiler :: #import "Compiler";
    #import "Basic";

    parent_options := Compiler.get_build_options();
    Compiler.set_build_options_dc(.{do_output = false});
    workspace := Compiler.compiler_create_workspace("blob_checks");
    options := Compiler.get_build_options(workspace);
    Compiler.copy_commonly_propagated_fields(parent_options, *options);
    options.output_path = parent_options.output_path;
    options.output_executable_name = "blob_checks";
    options.intermediate_path = sprint("%/.build/blob_checks", options.output_path);
    Compiler.set_build_options(options, workspace);
    Compiler.add_build_file(sprint("%blob_checks.jai", #filepath), workspace);
}
