/*
 * =====================================================================================
 *
 *       Filename:  elf.h
 *
 *    Description:  ELF 格式的部分定义
 *
 *        Version:  0.0.6Alpha
 *        Created:  2024年2月4日 10时29分37秒
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  PiEOS-Team
 *
 * =====================================================================================
 */

#ifndef INCLUDE_ELF_H_
#define INCLUDE_ELF_H_

#include "types.h"
#include "multiboot.h"

#define ELF32_ST_TYPE(i) ((i) & 0xf)

// ELF 格式区段头
typedef
struct elf_section_header_t {
    uint32_t name;
    uint32_t type;
    uint32_t flags;
    uint32_t addr;
    uint32_t offset;
    uint32_t size;
    uint32_t link;
    uint32_t info;
    uint32_t addralign;
    uint32_t entsize;
} __attribute__((acked)) elf_section_header_t;

// ELF 格式符号
typedef
struct elf_symbol_t {
    uint32_t name;
    uint32_t type;
    uint32_t flags;
    uint32_t addr;
    uint32_t offset;
    uint32_t size;
    uint32_t link;
    uint32_t info;
    uint32_t addralign;
    uint32_t entsize;
} __attribute__((packed)) elf_symbol_t;

// ELF 信息
typedef
struct elf_t {
    elf_symbol_t *symtab;
    uint32_t symtabsz;
    const char *strtab;
    uint32_t strtabsz;
} elf_t;

// 从 multiboot_t 结构获取信息 ELF
elf_t elf_from_multiboot(multiboot_t, *mb);

// 查看的符号信息 ELF
const char *elf_lookup_symbol(uint32_t addr, elf_t *elf);

#endif