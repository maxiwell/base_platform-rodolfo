# Variable that points to SystemC installation path
export SYSTEMC:=/home/jaineshdoshi/Documents/ArchC/systemcinstall
export LD_LIBRARY_PATH:=/home/jaineshdoshi/Documents/ArchC/systemcinstall/lib-linux64:$(LD_LIBRARY_PATH)

# Variable that points to TLM installation path
export TLM_PATH:=/home/jaineshdoshi/Documents/ArchC/systemcinstall/include

# Variable that points to ArchC installation path
#use with acinstall2 as ac_module.H is in acinstall2/include/archc
#copied ac_hltrace.H into /acinstall2/include/archc
export ARCHC_PATH:=/home/jaineshdoshi/Documents/ArchC/acinstall2

#check if neeeded
#added .../acinstall2/include/archc in PATH as ac_tlm_protocol.H was missing
export PATH:=/home/jaineshdoshi/Documents/ArchC/archc_mips_toolchain_64bit/mips-newlib-elf/:/home/jaineshdoshi/Documents/ArchC/acinstall2/include/archc:$(PATH)

TARGET=platform
EXE = $(TARGET).x

SRCS := main.cpp
OBJS := $(SRCS:.cpp=.o)
COMPONENTS := mips memory bus
HOST_OS := linux64

export LIB_DIR:=-L $(SYSTEMC)/lib-$(HOST_OS) \
		-L $(ARCHC_PATH)/lib \
		$(foreach c, $(COMPONENTS), -L $(c))

export INC_DIR:=-I $(SYSTEMC)/include \
		-I $(ARCHC_PATH)/include/archc \
		-I $(TLM_PATH) \
		$(foreach c, $(COMPONENTS), -I $(c)) 

export LIBS:= $(foreach c, $(COMPONENTS), -l$(c)) -lsystemc -larchc -lm

export LIBFILES:= $(foreach c, $(COMPONENTS), $(c)/lib$(c).a)

export CFLAGS:=-g

export CC:=g++



all: 
	for c in $(COMPONENTS); do echo " => Making" $$c ...; \
	    cd $$c; $(MAKE); cd ..; done
	echo " => Making sw ..."
	cd sw; $(MAKE)
	echo " => Making platform ..."
	$(MAKE) $(EXE)

clean:
	for c in $(COMPONENTS); do echo " => Making" $$c ...; \
	    cd $$c; $(MAKE) clean; cd ..; done	
	echo " => Making sw ..."
	cd sw ; $(MAKE) clean
	echo " => Making platform ..."
	rm -f $(OBJS) $(EXE) *~ *.o

#------------------------------------------------------
.SILENT:
#------------------------------------------------------
.SUFFIXES: .cc .cpp .o .x
#------------------------------------------------------
$(EXE): $(OBJS) $(LIBFILES)
	$(CC) $(CFLAGS) $(INC_DIR) $(LIB_DIR) -o $(EXE) $(OBJS) $(LIBS)
#------------------------------------------------------
main.o:
	$(CC) $(CFLAGS) $(INC_DIR) -c main.cpp
#------------------------------------------------------
#all: $(EXE)
#------------------------------------------------------
run: $(EXE)
#------------------------------------------------------
#------------------------------------------------------
distclean: clean
	./$(EXE) --load=sw/hello_world.mips
#------------------------------------------------------
.cpp.o:
	$(CC) $(CFLAGS) $(INC_DIR) -c $<
#------------------------------------------------------
.cc.o:
	$(CC) $(CFLAGS) $(INC_DIR) -c $<




