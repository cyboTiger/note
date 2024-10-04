


## To CoT or not to CoT? Chain-of-thought helps mainly on math and symbolic reasoning

These results paint a picture that CoT’s utility is often circumscribed by tool augmentation: 

+ on problems where CoT helps, we already have more powerful tools than CoT that we can employ

+ on “soft reasoning” problems like commonsense where no tools exist, we see limited benefit from CoT. 

This characterization has two major implications: 

+ First, CoT is unnecessary for many problems where it is widely employed: there exist more efficient prompting strategies that yield similar performance for much lower inference cost. 

+ Second, we see a critical need to move beyond prompt-based CoT to more sophisticated approaches based on search, interacting agents, or models more heavily fine-tuned for CoT. 

Future work can explore **how intermediate computation can be better used to solve challenging problems outside of the math and symbolic reasoning domains**

### My comment
I think the conclusion, i.e. use CoT to solve no-math/symbolic questions will be a potential field.

1. sparse cross attention

2. visual token selection

3. efficient fine tuning

都和sparsification