// --------------------------------------------------------------------------------
// SimpleBus_reg_model
// --------------------------------------------------------------------------------
class SimpleBus_reg_model extends uvm_reg_block;
    `uvm_object_utils(SimpleBus_reg_model)

    rand SimpleBus_reg_invert invert_h;
    uvm_reg_map SimpleBus_reg_map;

    function new(input string name="reg_model");
        super.new(name, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        invert_h = SimpleBus_reg_invert::type_id::create("invert");

        // function void configure (uvm_reg_block blk_parent, uvm_reg_file regfile_parent = null, string hdl_path = "")
        // Instance-specific configuration
        //
        // Specify the parent block of this register.
        // May also set a parent register file for this register,
        //
        // If the register is implemented in a single HDL variable,
        // its name is specified as the hdl_path.
        // Otherwise, if the register is implemented as a concatenation
        // of variables (usually one per field), then the HDL path
        // must be specified using the add_hdl_path() or
        // add_hdl_path_slice method. Configure
        invert_h.configure(this, null, "");
        invert_h.build();
        invert_h.add_hdl_path_slice("invert", 0, 1);

        // virtual function uvm_reg_map create_map (string name, uvm_reg_addr_t base_addr, int unsigned n_bytes, uvm_endianness_e endian, bit byte_addressing = 1)
        // Create an address map in this block
        //
        // Create an address map with the specified name, then
        // configures it with the following properties.
        //
        // base_addr          the base address for the map. All registers, memories,
        //                    and sub-blocks within the map will be at offsets to this
        //                    address
        // n_bytes            the byte-width of the bus on which this map is used
        // endian             the endian format. See uvm_endianness_e for possible
        //                    values
        // byte_addressing    specifies whether consecutive addresses refer are 1 byte
        //                    apart (TRUE) or n_bytes apart (FALSE). Default is TRUE.
        SimpleBus_reg_map = create_map("SimpleBus_reg_map", 0, 2, UVM_LITTLE_ENDIAN);
        SimpleBus_reg_map.add_reg(invert_h, 'h9, "RW");

        // for back-door access
        add_hdl_path("top.test_dut");
        lock_model();
    endfunction
endclass : SimpleBus_reg_model 
