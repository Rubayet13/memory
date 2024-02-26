program basetest (input clk, mem_intf INTF);

  driver_v2 DRVR;

  mailbox #(mem_trans) test2drvr;
  mem_trans item;
  semaphore sema;
  
  initial begin
    $display("test initiated");

    test2drvr = new();
    sema = new();
    DRVR = new(INTF, test2drvr, sema);

    fork
      DRVR.run();
    join_none

    reset();
    write(100, 1100);
    idle();
    read(100);

    @(negedge clk);
    $finish;
    
  end

  task reset();
    $display("\n", $time, "ns || [TEST] Running RESET");
    item = new();
    item.opp = RESET;

    test2drvr.put(item);
    sema.get();
    $display($time, "ns || [TEST] RESET Done");
  endtask

  task write(ADDR_VAL addr, DATA_VAL data);
    $display("\n", $time, "ns || [TEST] Running WRITE");
    item = new();
    item.data_in = data;
    item.addr = addr;
    item.opp = WRITE;

    test2drvr.put(item);
    sema.get();
    $display($time, "ns || [TEST] WRITE Done");
  endtask

  task idle();
    $display("\n", $time, "ns || [TEST] Running IDLE");
    item = new();
    test2drvr.put(item);
    item.opp = IDLE;
    sema.get();
    $display($time, "ns || [TEST] IDLE Done");
  endtask

  task read(ADDR_VAL addr);
    $display("\n", $time, "ns || [TEST] Running READ");
    item = new();
    item.addr = addr;
    item.opp = READ;

    test2drvr.put(item);
    sema.get();
    $display($time, "ns || [TEST] READ Done");
  endtask

endprogram



// INTF.rst_n <= 0;
// INTF.rd_wr <= 0;
// INTF.enb <= 0;
// INTF.data_in <= 0;
// INTF.addr <= 0;
// @(negedge clk);

// INTF.rst_n <= 1;
// INTF.rd_wr <= 0;
// INTF.enb <= 1;
// INTF.data_in <= 10;
// INTF.addr <= 110;
// @(negedge clk);

// INTF.rd_wr <= 1;
// INTF.enb <= 1;
// INTF.addr <= 110;
// @(negedge clk);
// @(negedge clk);

// repeat (10) begin
//   @(negedge clk);
// end

// $finish;



// function compare (int exp_value, observed_value);

//   if (exp_value === observed_value) begin
//     $display($time, "ns || Read data that was written earlier || PASSED");
//     PASSED++;
//   end

//   else begin
//     $display($time, "ns || Read data that was not written earlier || FAILED");
//     FAILED++;
//     address_failed_for = new[address_failed_for.size() +1](address_failed_for);
//     address_failed_for[address_failed_for.size() +1] = INTF.addr;
//   end

// endfunction
