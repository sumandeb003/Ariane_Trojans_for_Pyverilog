import os, sys
sys.path.append(os.path.dirname(sys.path[0]))
from hw2vec.config import Config
from hw2vec.hw2graph import *
from hw2vec.graph2vec.models import *

cfg = Config(sys.argv[1:])

''' prepare graph data''' 
nx_graphs = [] #list of graphs of all the circuits in the hw_project_path
hw2graph = HW2GRAPH(cfg)
for hw_project_path in hw2graph.find_hw_project_folders():
      hw_graph = hw2graph.code2graph(hw_project_path) #pre-process (flatten,remove comments, remove underscores, rename as topModule.v) and process (enerate AST/CFG/DFG (JSON format) of the topModule.v)
      nx_graphs.append(hw_graph)

data_proc = DataProcessor(cfg)
for hw_graph in nx_graphs:
     data_proc.process(hw_graph)#normalize the graph and create node-feature vectors X and adjacency matrix A
data_proc.cache_graph_data(cfg.data_pkl_path)

#''' prepare graph data''' 
#if not cfg.data_pkl_path.exists():
#    '''converting graph using hw2graph '''
#    print(f'if not cfg.data_pkl_path.exists():')
#    nx_graphs = [] #list of graphs of all the circuits in the hw_project_path
#    hw2graph = HW2GRAPH(cfg)
#    for hw_project_path in hw2graph.find_hw_project_folders():
#      hw_graph = hw2graph.code2graph(hw_project_path) #pre-process (flatten,remove comments, remove underscores, rename as topModule.v) and process (enerate AST/CFG/DFG (JSON format) of the topModule.v)
#      nx_graphs.append(hw_graph)

#    data_proc = DataProcessor(cfg)
#    for hw_graph in nx_graphs:
#     data_proc.process(hw_graph)#normalize the graph and create node-feature vectors X and adjacency matrix A
#    data_proc.cache_graph_data(cfg.data_pkl_path)
    
#else:
#    ''' reading graph data from cache '''
#    print(f'if cfg.data_pkl_path.exists():')
#    data_proc = DataProcessor(cfg)
#    data_proc.read_graph_data_from_cache(cfg.data_pkl_path) #sets self.graph_data

''' prepare dataset '''
TROJAN = 1
NON_TROJAN = 0

all_graphs = data_proc.get_graphs() #stores self.graph_data
for data in all_graphs:
    if "TjFree" == data.hw_type:
        data.label = NON_TROJAN
    else:
        data.label = TROJAN

print(f'Total number of all_graphs: {len(all_graphs)}')

my_graphs = [data for data in all_graphs if data.hw_name == 'pyVerilog']
all_graphs = [data for data in all_graphs if data.hw_name != 'pyVerilog']
print(f'Total number of all_graphs: {len(all_graphs)}')
print(f'Total number of my_graphs: {len(my_graphs)}')
print(f'my_graphs: {my_graphs}')

train_graphs, test_graphs = data_proc.split_dataset(ratio=cfg.ratio, seed=cfg.seed, dataset=all_graphs)
print(f'================================')
print(f'Total number of Training graphs: {len(train_graphs)}')
for graph in train_graphs:
	print(f'Training Circuit: {graph.hw_name}, Type: {graph.hw_type}, Label: {graph.label}')
print(f'================================')
print(f'================================')
print(f'Total number of Test graphs: {len(test_graphs)}')
for graph in test_graphs:
	print(f'Test Circuit: {graph.hw_name}, Type: {graph.hw_type}, Label: {graph.label}')
print(f'================================')
train_loader = DataLoader(train_graphs, shuffle=True, batch_size=cfg.batch_size)
valid_loader = DataLoader(test_graphs, shuffle=True, batch_size=1)
my_loader = DataLoader(my_graphs, shuffle=True, batch_size=1)

''' model configuration '''
model = GRAPH2VEC(cfg)
if cfg.model_path != "":
    print(f'if cfg.model_path != "": ')
    model_path = Path(cfg.model_path)
    if model_path.exists():
        model.load_model(str(model_path/"model.cfg"), str(model_path/"model.pth"))
else:
    print(f'if not cfg.model_path != "":')
    convs = [
        GRAPH_CONV("gcn", data_proc.num_node_labels, cfg.hidden),
        GRAPH_CONV("gcn", cfg.hidden, cfg.hidden)
    ]
    model.set_graph_conv(convs)

    pool = GRAPH_POOL("sagpool", cfg.hidden, cfg.poolratio)
    model.set_graph_pool(pool)

    readout = GRAPH_READOUT("max")
    model.set_graph_readout(readout)

    output = nn.Linear(cfg.hidden, cfg.embed_dim)
    model.set_output_layer(output)

''' training '''
model.to(cfg.device)
trainer = GraphTrainer(cfg, class_weights=data_proc.get_class_weights(train_graphs))
trainer.build(model)
trainer.train(train_loader, valid_loader)

''' evaluating and inspecting '''
trainer.evaluate(cfg.epochs, train_loader, valid_loader)
vis_loader = DataLoader(all_graphs, shuffle=False, batch_size=1)
trainer.visualize_embeddings(vis_loader, "./")
'''===================DETECTING MY TROJANS==================='''
print(f'===================DETECTING MY TROJANS NOW===================')
myG_avg_loss, myG_labels_tensor, myG_outputs_tensor, myG_preds, myG_node_attns = trainer.inference(my_loader)
print(f'Label: {myG_labels_tensor}')
print(f'Prediction: {myG_preds}')
