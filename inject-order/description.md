# Description

This page contains descriptions for all strategies listed on "builder" tap. All strategies can be selected and used in conjunction with the rest strategies.

- **Fixed order** applies no control to item sequences. Items are presented for all participants as they originally stays on a scale.
- **Simple randomization**, as its name suggested, fully randomizes the presentation order of the scale for each participant.
- **Permuted-Subblock Randomization (PSR)** splits sequences into subblocks, with each subblock having one item per factor(subscale). Then PSR randomly permute orders within each subblocks and concatenate them to a new sequence. PSR is independently conducted for each participant. For details, please visit [Liang and Barr, 2024](https://pubmed.ncbi.nlm.nih.gov/39666537/).
- **Latin Square** generates a $k \times k$ square where $k$ represents item numbers. Each item only appears once per row and per column in this square. Each row of this square will be seen as a presentation order, and will be assigned to participants.
- **Grouping** methods cluster items under the same factor(subscale) together. Currently, four variations are available:
    - *Fixed Grouping* fixes the factor sequence and item sequences per factor across participants, which means all participant receive the same 'grouping' order.
    - *Random Grouping - factor* independently randomizes factor sequences for every participant, but remains the same item sequence within factors across participants. That being said, item sequences within each factors are always identical, regardless factor sequence.
    - *Random Grouping - item* independently randomizes item sequences within factors for every participant, but remains the same factor sequence across participants.
    - *Random Grouping - both* independently randomizes both factor sequence and item sequence for each participant.
- **Cycling** methods cycles items following a specific factor cycle order for each participant. Currently, four variations are available:
    - *Fixed Cycling* fixes the cycle sequence and item assignments per cycle across participants, which means all participant receive the same 'cycling' order.
    - *Random Cycling - factor* independently randomizes the cycle order for each participants, but remains the same item allocations per cycle across participants. That means, they were presented with the same item the $n_{th}$ time they response to items from a specific factor, regardless item position within a cycle.
    - *Random Cycling - item* retains identical cycle order across participants, but independently randomize item allocation for each position for each participant. That means, every participant receive the same cycle order, but even under the same cycle, they might not receive the same items.
    - *Random Cycling - both* randomizes both cycle order and item allocations for all participants.
	  
