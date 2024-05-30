package com.example.university;

public class University {
    private String name;
    private int[] data;

    public University(String name, int objectSize) {
        this.name = name;
        this.data = new int[objectSize]; // 256 * 4 bytes = 1024 bytes
        for (int i = 0; i < data.length; i++) {
            data[i] = i; // Initialize array to ensure memory allocation
        }
    }

    public String getName() {
        return name;
    }

    public int[] getData() {
        return data;
    }
}
