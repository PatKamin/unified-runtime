"""
 Copyright (C) 2023 Intel Corporation

 Part of the Unified-Runtime Project, under the Apache License v2.0 with LLVM Exceptions.
 See LICENSE.TXT
 SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

"""
import os
import re

from templates import helper as th


def _get_simple_types_objs(specs):
    return [obj for spec in specs for obj in spec['objects'] if re.match(r"enum|struct", obj['type'])]

def _get_param_types_objs(specs, meta, namespace, tags):
    return [obj for tbl in th.get_pfncbtables(specs, meta, namespace, tags) for obj in tbl['functions']]

def _get_simple_types_funcs(namespace, tags, specs):
    x = tags['$x']
    simple_types_funcs = []
    for obj in _get_simple_types_objs(specs):
        func_name = th.make_func_name_with_prefix(f'{x}Print', obj['name'])
        func_args = []
        obj_type_name = ""
        arg_name = ""
        if re.match(r"enum", obj['type']):
            obj_type_name = th.make_enum_name(namespace, tags, obj)
            arg_name = "value"
            func_args.append(f"{obj['type']} {obj_type_name} {arg_name}")
        elif re.match(r"struct", obj['type']):
            obj_type_name = th.make_type_name(namespace, tags, obj)
            arg_name = "params"
            func_args.append(f"const {obj['type']} {obj_type_name} {arg_name}")
        func_args.extend(['char *buffer', 'const size_t buff_size', 'size_t *out_size'])

        func_dict = {'base_type': obj['type'],
                    'ur_type_name': obj_type_name,
                    'arg_name': arg_name,
                    'name': func_name,
                    'args': func_args
                   }
        simple_types_funcs.append(func_dict)
    return simple_types_funcs

def _get_param_types_funcs(specs, meta, namespace, tags):
    x = tags['$x']
    pfncbtables_funcs = []
    for obj in _get_param_types_objs(specs, meta, namespace, tags):
        func_args = []
        obj_type_name = th.make_pfncb_param_type(namespace, tags, obj)
        func_name = th.make_func_name_with_prefix(f'{x}Print', obj_type_name)
        arg_name = 'params'
        base_type = 'struct'

        func_args.append(f"const {base_type} {obj_type_name} *{arg_name}")
        func_args.extend(["char *buffer", "const size_t buff_size", "size_t *out_size"])

        func_dict = {'base_type': base_type,
                     'ur_type_name': obj_type_name,
                     'arg_name': arg_name,
                     'name': func_name,
                     'args': func_args
                    }
        pfncbtables_funcs.append(func_dict)
    return pfncbtables_funcs

def get_api_types_funcs(specs, meta, namespace, tags):
    api_types_funcs = _get_simple_types_funcs(namespace, tags, specs)
    api_types_funcs.extend(_get_param_types_funcs(specs, meta, namespace, tags))
    return api_types_funcs

def get_extras_funcs(tags):
    extras_funcs = []
    func_comment = []

    with open(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'print.hpp.mako'), 'r') as file:
        extras_namespace = False
        for line in file:
            if re.match('namespace extras {', line):
                extras_namespace = True
            elif re.match('} // namespace extras', line):
                extras_namespace = False
            
            if extras_namespace:
                if re.match('///', line):
                    func_comment.append(line)
                    if re.search('RESULT_ERROR_INVALID_NULL_POINTER', line):
                        func_comment.append('///         - `NULL == buffer`\n')
                elif re.match(r'.*_APIEXPORT .*_APICALL print\w+\(.*\)', line):
                    func_comment.append('///     - ::${X}_RESULT_ERROR_INVALID_SIZE\n')
                    func_comment.append('///         - `buff_size < out_size`\n')
                    func_name = re.search(r'print\w+(?=\()', line).group(0)
                    func_c_name = tags['$x'] + func_name[0].capitalize() + func_name[1:]
                    func_args = re.search(r'(?<=\().*(?=\))', line).group(0).split(',')
                    func_c_args = [arg for arg in func_args if not re.match('std::ostream', arg)]
                    func_comment_str = "".join(func_comment)
                    extras_funcs.append({
                                         'c': {'name': func_c_name,
                                               'args': func_c_args},
                                         'cpp': {'name': func_name,
                                                 'args': func_args},
                                         'comment': func_comment_str})
                    func_comment.clear()
    return extras_funcs
