// --------------------------------------------------------------------------------
//  Reg Module
// --------------------------------------------------------------------------------
class SimpleBus_reg_invert extends uvm_reg;
    `uvm_object_utils(SimpleBus_reg_invert)

    rand uvm_reg_field reg_data;

    function new(string name="reg_invert");
        // function new (string name = "", int unsigned n_bits, int has_coverage)
        // Create a new instance and type-specific configuration
        //
        // Creates an instance of a register abstraction class with the specified
        // name.
        //
        // n_bits specifies the total number of bits in the register.
        // Not all bits need to be implemented.
        // This value is usually a multiple of 8.
        //
        // has_coverage specifies which functional coverage models are present in
        // the extension of the register abstraction class.
        // Multiple functional coverage models may be specified by adding their
        // symbolic names, as defined by the uvm_coverage_model_e type.
        super.new(name, 16, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
        reg_data = uvm_reg_field::type_id::create("reg_data");
        //function void configure (uvm_reg parent,
        //                         int unsigned regfield size,
        //                         int unsigned lsb_pos,
        //                         string access,
        //                         bit volatile,
        //                         uvm_reg_data_t reset,
        //                         bit has_reset,
        //                         bit is_rand,
        //                         bit individually_accessible)
        reg_data.configure(this, 1, 0, "RW", 0, 0, 1, 1, 0);
    endfunction
endclass