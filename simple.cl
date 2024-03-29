__kernel void simple(__global int* a) {
    uint idx = get_global_id(0);
    for (int i = 0; i < 1000; ++i)
        a[idx] += 1;
}
