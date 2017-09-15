#*******************************************************************************
#    
#	Copyright (C) 2017 Marcelo S. Reis, Gustavo Estrela
#
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program.  If not, see <http:www.gnu.org/licenses/>.
#
#*******************************************************************************/


CC=gcc
CFLAGS=-ansi -pedantic -Wall
BIN_DIR=bin
SRC_DIR=src

all: $(BIN_DIR)/filter_Chinese_handwriting_sample

$(BIN_DIR)/filter_Chinese_handwriting_sample: $(SRC_DIR)/filter_Chinese_handwriting_sample.c
	$(CC)  $(CFLAGS) $< -o $@

clean:
	rm bin/filter_Chinese_handwriting_sample
