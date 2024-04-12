// Copyright (C) 2023 Intel Corporation
// Part of the Unified-Runtime Project, under the Apache License v2.0 with LLVM Exceptions.
// See LICENSE.TXT
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

/*
This binary is meant to be run with a libFuzzer. It generates part of API calls in different
order in each iteration trying to crash the application. There are some initial scenarios
in the corpus directory for reaching better coverage of tests.
*/

#include <fstream>
#include <iostream>
#include <iterator>
#include <vector>

#include "ur_api.h"

int ur_program_create_with_il(ur_context_handle_t context, [[maybe_unused]] ur_device_handle_t device, const std::vector<uint8_t> &il_bin) {
    ur_program_handle_t program;

    if (il_bin.empty()) {
        std::cerr << "Empty IL binary\n";
        return -1;
    }

    urProgramCreateWithIL(context, il_bin.data(), il_bin.size(), nullptr,
                          &program);
    urProgramBuild(context, program, nullptr);

    urProgramRelease(program);

    return 0;
}

int main(int argc, char **argv) {
    if (argc != 2) {
        std::cerr << "Usage: " << argv[0] << " <input_file>\n";
        return 1;
    }

    std::ifstream file(argv[1], std::ios::binary);
    if (!file) {
        std::cerr << "Failed to open file: " << argv[1] << "\n";
        return 1;
    }

    // Read the entire file into a vector
    std::vector<uint8_t> kernel_code((std::istreambuf_iterator<char>(file)),
                                     std::istreambuf_iterator<char>());

    // Call the functions in the specified order
    if (urLoaderInit(0, nullptr) != UR_RESULT_SUCCESS) {
        std::cerr << "urLoaderInit failed\n";
        return -1;
    }

    constexpr uint32_t num_entries = 1;
    ur_adapter_handle_t adapter;
    ur_platform_handle_t platform;
    ur_device_handle_t device;
    ur_context_handle_t context;
    uint32_t num_adapters = 0;
    uint32_t num_platforms = 0;
    uint32_t num_devices = 0;

    if (urAdapterGet(0, nullptr, &num_adapters) != UR_RESULT_SUCCESS) {
        std::cerr << "urAdapterGet failed\n";
        return -1;
    }

    if (num_adapters == 0) {
        std::cerr << "No adapters found\n";
        return -1;
    }

    if (urAdapterGet(num_entries, &adapter, nullptr) != UR_RESULT_SUCCESS) {
        std::cerr << "adapter get failed!\n";
        return -1;
    }

    if (adapter == nullptr) {
        std::cerr << "Adapter is nullptr\n";
        return -1;
    }

    if (urPlatformGet(&adapter, 1, 0, nullptr, &num_platforms) !=
        UR_RESULT_SUCCESS) {
        std::cerr << "Failed to get number of platforms!\n";
        return -1;
    }

    if (num_platforms == 0) {
        std::cerr << "No platforms found\n";
        return -1;
    }

    if (urPlatformGet(&adapter, 1, num_entries, &platform, nullptr) !=
        UR_RESULT_SUCCESS) {
        std::cerr << "Second urPlatformGet failed\n";
        return -1;
    }

    if (adapter == nullptr) {
        std::cerr << "Adapter is nullptr\n";
        return -1;
    }

    ur_device_type_t device_type = UR_DEVICE_TYPE_GPU;
    if (urDeviceGet(platform, device_type, 0, nullptr, &num_devices) !=
        UR_RESULT_SUCCESS) {
        std::cerr << "First urDeviceGet failed\n";
        return -1;
    }

    if (num_devices == 0) {
        std::cerr << "No devices found\n";
        return -1;
    }

    if (urDeviceGet(platform, device_type, num_entries, &device, nullptr) !=
        UR_RESULT_SUCCESS) {
        std::cerr << "Second urDeviceGet failed\n";
        return -1;
    }

    if (device == nullptr) {
        std::cerr << "Device is nullptr\n";
        return -1;
    }

    if (urContextCreate(num_entries, &device, nullptr, &context) !=
        UR_RESULT_SUCCESS) {
        std::cerr << "urContextCreate failed\n";
        return -1;
    }

    if (context == nullptr) {
        std::cerr << "Context is nullptr\n";
        return -1;
    }

    if (ur_program_create_with_il(context, device, kernel_code) != 0) {
        std::cerr << "ur_program_create_with_il failed\n";
        return -1;
    }

    urContextRelease(context);
    urAdapterRelease(adapter);
    urLoaderTearDown();

    return 0;
}
