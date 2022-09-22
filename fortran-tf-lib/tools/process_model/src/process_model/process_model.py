import click
from jinja2 import PackageLoader, Environment


env = Environment(
    loader=PackageLoader(__name__),
    lstrip_blocks=True,
    trim_blocks=True,
)


@click.command()
@click.argument('model_dirs', type=click.Path(exists=True,
                file_okay=False, dir_okay=True), nargs=-1, required=True)
@click.option('-o', '--output-file', default='-', type=click.File(mode='wt'),
              help='Where to send Fortran output.')
@click.option('-t', '--tag-set', default='serve', type=click.STRING,
              help='tag-set to use (default `serve`).')
@click.option('-s', '--signature-def', default='serving_default',
              type=click.STRING, help='signature def to use (default '
              '`serving_default`)')
@click.option('--indent', default=4, type=click.INT,
              help='Indentation level of output code (default 4)')
def main(model_dirs, output_file, tag_set, signature_def, indent):
    '''
    Utility to read a SavedModel TensorFlow model and export the necessary
    Fortran code to allow it to be interfaced with the fortran-tf library.

    MODEL_DIR contains a TensorFlow SavedModel.
    '''

    import sys
    from tensorflow.python.tools import saved_model_utils
    for model_dir in model_dirs:
        # Tag-sets
        tag_sets = saved_model_utils.get_saved_model_tag_sets(model_dir)

        for ts in sorted(tag_sets):
            tag_string = ','.join(sorted(ts))
            if tag_string == tag_set:
                break
        else:
            print(f'The SavedModel {model_dir}\ndoes not contain tag-set '
                  '"{tag_set}".')
            print('It contains the following tag-sets:')
            for ts in sorted(tag_sets):
                print('%r' % ','.join(sorted(ts)))
            sys.exit(1)

        # Signature defs
        meta_graph = saved_model_utils.get_meta_graph_def(model_dir, tag_set)
        signature_def_map = meta_graph.signature_def
        if signature_def not in signature_def_map:
            print(f'The SavedModel {model_dir}\ndoes not contain'
                  ' signature-def "{signature_def}".')
            print('The model\'s MetaGraphDef contains SignatureDefs with the '
                  'following keys:')
            for signature_def_key in sorted(signature_def_map.keys()):
                print('SignatureDef key: \"%s\"' % signature_def_key)
            sys.exit(1)

        input_tensors = signature_def_map[signature_def].inputs
        output_tensors = signature_def_map[signature_def].outputs

    tags = tag_set.split(',')
    print(render_template('module_start.F90', indent,
          tags=tags, model_dirs=model_dirs), file=output_file)

#    output_module_init(tag_set, model_dir, indent)
#    for inp_k in input_tensors:
#        print(inp_k, '\n', input_tensors[inp_k])


def render_template(template_name, indent, **kwargs):
    '''
    Renders a template, replaces the tabs with `indent`
    number of spaces, returns the result.
    '''
    t = env.get_template(template_name)
    s = t.render(kwargs)
    s = s.replace('\t', ' ' * indent)
    return s


def output_module_init(tag_set, model_dirs, indent_level):
    '''
    Outputs the Fortran code needed to define and init the module.
    The init routine will load the ML model and store it in a module
    variable.
    '''

    tag_set = 'serve,gpu'
    tags = tag_set.split(',')
    max_tag_len = max([len(t) for t in tags])


if __name__ == '__main__':
    main()
