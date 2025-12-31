" --- BASIC ---
syntax on               " Bật tô màu cú pháp
set number              " Hiện số dòng
set cursorline          " Highlight dòng hiện tại
set mouse=a             " Cho phép dùng chuột để scroll/click

" --- INDENTATION ---
set tabstop=4           " Tab = 4 spaces
set shiftwidth=4
set expandtab           " Dùng space thay cho tab thật
set autoindent          " Tự động thụt lề khi xuống dòng
set smartindent

" --- SEARCH ---
set hlsearch            " Highlight kết quả tìm kiếm
set incsearch           " Tìm kiếm ngay khi đang gõ
set ignorecase          " Tìm không phân biệt hoa thường
set smartcase           " ...trừ khi có chữ hoa

" --- SYSTEM ---
set nocompatible        " Không cần tương thích ngược với vi cổ điển
set clipboard=unnamed   " (Optional) Dùng clipboard hệ thống nếu hỗ trợ
colorscheme desert      " Theme mặc định dễ nhìn nhất trên server
