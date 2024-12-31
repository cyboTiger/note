> 考试时间：01月02日(08:00-10:00)

!!! note "资源"

    + [历年卷23-24](https://www.cc98.org/topic/5800194)

    + [历年卷22-23](https://www.cc98.org/topic/5504808)

??? note "凯哥的解释"
    differences among dynamic scheduling algorithms:
    1. Scoreboarding:
    IF Issue Read-Operands Ex MEM WB
    in comparison with traditional pipeline, still in-order issue, support dynamic scheduling (both out-of-order execution and out-of-order completion);
    does NOT support register renaming, therefore, [lec07-P114] even if an instruction has been issued to a function unit (without structural hazard in Issue), the instruction should wait there; UNTIL NO DATA HAZARD (including all kinds of data hazards: RAW, WAE, WAR) can the function unit read operands for the instruction;

    2. Tomasulo's Algorithm
    in-order issue, still support out-of-order execution and out-of-order completion;
    in comparison with Scoreboarding, [lec07-P146] ELIMINATE STALLS for WAW and WAR hazards through Register Renaming;
    however, still cannot deal with branch instructions with prediction: [lec07-P186] no instr is allowed to execute until a branch that preceds the instruction in program order has completed;

    3. Tomasulo's Algorithm with Hardware Speculation
    speculate on branch outcome;
    issue and execute instructions according to the prediction result if possible;
    commit results till prediction is determined;
    flush/undo results/effects if prediction is incorrect;
    in orther words, even if an instruction is executed and generated results, its results still cannot take effect immediately, in case any of its depedent branch instruction turns out to follow another execution path; with sufficient status and hardware logic, this can be determined in advance; however, the presented version on textbook does not track such status, so does not quite know about whether an instruction relates to a pending branch instruction or not, then the simple design policy is to treat all instructions after a branch instruction (in terms of program order) as ones depending on the branch outcome; reorder-buffer exactly follows this policy, and flushes all instructions' info next to a branch instruction once the branch is determined to have followed an incorrect prediction; this further implies that regardless when an instruction has executed and generated results, they need to strictly follow the program order to commit their results.
    therefore: IN-ORDER issue, out-of-order execution, IN-ORDER COMMIT


    further discussions: out-of-order instruction issue?
    same as many of our discussions, if sufficient hardware resources (and related design policies) are provided, it is also possible to achieve out-of-order instruction issue;
    for example: besides the traditional single FIFO instruction queue, functional units, reservation stations, etc, if datapath introduces extra components to temporarily hold instructions that cannot be issued/executed in pipelines we discussed, scheduler can simply put such instruction to this extra component, then the next instruction becomes instruction-queue head and might be issued to a function-unit/reservation-station;
    apparently, this extra component acts like another instruction queue, please do not confuse this simply with hardware with multiple instruction queues; the latter design uses multiple instruction queues, OS (likely with the help of compiler) decides which set of instructions of a program are put to which queue, but inside a specific queue, may still follow in-order issue.


    1. Issue—If a functional unit for the instruction is free and no other active instruction has the same destination register, the scoreboard issues the instruction to the functional unit and updates its internal data structure. This step replaces a portion of the ID step in the RISC V pipeline. By ensuring that no other active functional unit wants to write its result into the destination register, we guaran- tee that WAW hazards cannot be present. If a structural or WAW hazard exists, then the instruction issue stalls, and no further instructions will issue until these hazards are cleared. When the issue stage stalls, it causes the buffer between instruction fetch and issue to fill; if the buffer is a single entry, instruction fetch stalls immediately. If the buffer is a queue with multiple instructions, it stalls when the queue fills.

    2. Read operands—The scoreboard monitors the availability of the source oper- ands. A source operand is available if no earlier issued active instruction is going to write it. When the source operands are available, the scoreboard tells the functional unit to proceed to read the operands from the registers and begin execution. The scoreboard resolves RAW hazards dynamically in this step, and instructions may be sent into execution out of order. This step, together with issue, completes the function of the ID step in the simple RISC V pipeline.

    3. Execution—The functional unit begins execution upon receiving operands. When the result is ready, it notifies the scoreboard that it has completed execu- tion. This step replaces the EX step in the RISC V pipeline and takes multiple cycles in the RISC V FP pipeline.

    4. Write result—Once the scoreboard is aware that the functional unit has completed execution, the scoreboard checks for WAR hazards and stalls the completing instruction, if necessary.