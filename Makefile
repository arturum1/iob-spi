#
# TOP MAKEFILE
#

#
# SIMULATE
#

SPI_DIR:=.
include core.mk

sim:
ifeq ($(SIM_SERVER), localhost)
	make -C $(SIM_DIR) run SIMULATOR=$(SIMULATOR)
#else
#	ssh $(SIM_USER)@$(SIM_SERVER) "if [ ! -d $(USER)/$(REMOTE_ROOT_DIR) ]; then mkdir -p $(USER)/$(REMOTE_ROOT_DIR); fi"
#	make -C $(SIM_DIR) clean
#	rsync -avz --delete --exclude .git $(SPI_DIR) $(SIM_USER)@$(SIM_SERVER):$(USER)/$(REMOTE_ROOT_DIR)
#	ssh $(SIM_USER)@$(SIM_SERVER) 'cd $(USER)/$(REMOTE_ROOT_DIR); make -C $(SIM_DIR) run SIMULATOR=$(SIMULATOR) SIM_SERVER=localhost'
endif

sim-waves: $(SIM_DIR)/spi_fl_tb.vcd $(SIM_DIR)/waves.gtkw
	gtkwave $^ &

sim-clean:
ifeq ($(SIM_SERVER), localhost)
	make -C $(SIM_DIR) clean
#else 
#	rsync -avz --delete --exclude .git $(SPI_DIR) $(SIM_USER)@$(SIM_SERVER):$(USER)/$(REMOTE_ROOT_DIR)
#	ssh $(SIM_USER)@$(SIM_SERVER) 'cd $(USER)/$(REMOTE_ROOT_DIR); make clean SIM_SERVER=localhost FPGA_SERVER=localhost'
endif

#
# IMPLEMENT FPGA
#

fpga:
ifeq ($(FPGA_SERVER), localhost)
	make -C $(FPGA_DIR) run DATA_W=$(DATA_W)
else 
	ssh $(FPGA_USER)@$(FPGA_SERVER) "if [ ! -d $(USER)/$(REMOTE_ROOT_DIR) ]; then mkdir -p $(USER)/$(REMOTE_ROOT_DIR); fi"
	rsync -avz --delete --exclude .git $(SPI_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(USER)/$(REMOTE_ROOT_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'cd $(USER)/$(REMOTE_ROOT_DIR); make -C $(FPGA_DIR) run FPGA_FAMILY=$(FPGA_FAMILY) FPGA_SERVER=localhost'
	mkdir -p $(FPGA_DIR)/$(FPGA_FAMILY)
	scp $(FPGA_USER)@$(FPGA_SERVER):$(FPGA_USER)/$(REMOTE_ROOT_DIR)/$(FPGA_DIR)/$(FPGA_FAMILY)/$(FPGA_LOG) $(FPGA_DIR)/$(FPGA_FAMILY)
endif

fpga-clean:
ifeq ($(FPGA_SERVER), localhost)
	make -C $(FPGA_DIR) clean
else 
	rsync -avz --delete --exclude .git $(SPI_DIR) $(FPGA_USER)@$(FPGA_SERVER):$(USER)/$(REMOTE_ROOT_DIR)
	ssh $(FPGA_USER)@$(FPGA_SERVER) 'cd $(USER)/$(REMOTE_ROOT_DIR); make clean SIM_SERVER=localhost FPGA_SERVER=localhost'
endif

#
# DOCUMENT
#

doc:
	make -C document/$(DOC_TYPE) $(DOC_TYPE).pdf

doc-clean:
	make -C document/$(DOC_TYPE) clean

doc-pdfclean:
	make -C document/$(DOC_TYPE) pdfclean

clean: sim-clean doc-clean fpga-clean

.PHONY: sim sim-waves doc-clean fpga-clean clean
