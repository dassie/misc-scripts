#!/usr/bin/ruby

=begin
This is a script I wrote for a networking assignment.
It accepts a text-file that describes a graph as a
command-line input. It will output the shortest path
from the first node in the list to all other nodes as
computed by Dijkstra's algorithm. It will also generate
a shortest-path table as computed by the Bellman-Ford
algorithm.

The input file must be formatted like so:

[number of nodes] [number of edges]
[list of node separated by spaces]
[na] [nb] [distance from na to nb]
[nc] [na] [distance from nc to na]
.
.
.
=end

INFINITY = 2**32

class Bellman_Ford
	#'u' and 'v' are the nodes connected by Edge, 'w' is the length of the edge
	Edge = Struct.new(:u, :v, :w)
	
	def initialize(node_network, fstream)
		@graph = node_network
		@edges = Array.new
		@fout = fstream
		
		#These loops basically add each edge in the graph to the Edge array, @edges
		@graph.each do |k, v|
			@edges.push(Edge.new(k, k, 0))
			v[:neighbors].each do |n|
				e = Edge.new(k, n.name.to_s, n.distance.to_i)
				@edges.push(e) if !(@edges.include?(e))
			end
		end
	end

	def bellman_ford(src)
		@d = {}
		
		@graph.each_key do |k|
			if (k == src) then
				@d[k] = 0
			else
				@d[k] = INFINITY
			end
		end
		
		for i in (1..@d.size) do 
			@edges.each do |e|
				@d[e.v] = @d[e.u] + e.w if ((@d[e.u] + e.w) < @d[e.v])
			end
		end
	end

	def run
		@fout.print("  ")
		@graph.each_key do |k|
			@fout.print(k, " ")
		end
		@fout.print("\n")
		
		#Loop through each node in the graph
		#1. Run the bellman_ford function on the node
		#2. Print a new row in the table for that node
		@graph.each_key do |n1|
			@fout.print(n1, " ")
			bellman_ford(n1)
			@graph.each_key do |n2|
				@fout.printf("%d ", @d[n2])
			end
			@fout.print("\n")
		end
	end
	
end

class Dijkstra
	def initialize(node_network, fstream)
		@nodes = Array.new
		@graph = {}
		@fout = fstream
		
		node_network.each do |k, v|
			v[:neighbors].each do |n|
				add_edge(k.to_s, n.name.to_s, n.distance.to_i)
			end
		end
		#this defines graph as a hash-table. Each key will be a node name; said node will have associated with it
		#an edge(another node name) and the magnitude/distance of the edge
	end
	
	def add_edge(src, dest, dist)
		#src = source node
		#dest = destination nodes
		#mag = magnitude of the edge on the graph
		
		#simply add an entry for the source and the destination with the same magnitude for each
		#Note: graph is acting as an array of hash-tables
		if !(@graph.has_key?(src))
			@graph[src] = {dest => dist}
		else
			@graph[src][dest] = dist       
		end
		
		if !(@graph.has_key?(dest))
			@graph[dest] = {src => dist}
		else
			@graph[dest][src] = dist
		end
		
		if !(@nodes.include?(src))
			@nodes.push(src)
		end
		if !(@nodes.include?(dest))
			@nodes.push(dest)
		end
	end
	
	def dijkstra(src)
		@distance = {} #The distance and previous node vectors behave as hash-tables
		@previous = {} #Each one's key is the source node and the value is either the distance or the previous node in the shortest path
		
		@nodes.each do |n|
			@distance[n] = INFINITY
			@previous[n] = -1
		end
		
		@distance[src] = 0 #Distance from src->src is 0
		q = @nodes.compact #Q is the set of all nodes in the graph to iterate over
		
		while (q.size > 0)
			#Find node in Q with smallest smallest distance in @distance
			u = nil
			q.each do |min|
				u = min if (!u or (@distance[min] and @distance[min] < @distance[u]))
			end
			
			break if (@distance[u] == INFINITY)
			
			q.delete(u) #Remove u from Q
			
			@graph[u].keys.each do |v|
				alt = @distance[u] + @graph[u][v]
				if (alt < @distance[v])
					@distance[v] = alt
					@previous[v] = u
				end
			end
		end
	end

	def print_path(dest, first_iteration)
		if (@previous[dest] != -1)
			print_path(@previous[dest], false)
		end
		
		@fout.print(first_iteration ? dest.to_s : "#{dest.to_s}-")
	end
	
	def find_shortest_path(src)
		dijkstra(src)
		@nodes.each do |n|
			if (n != src)
				@fout.print("#{n.to_s}: ")
				print_path(n, true)
				@fout.print(" #{@distance[n]}\n")
			end
		end
	end

end

#Main program starts here...

if (ARGV.length == 0) then
	puts "Error: need input file as argument!"
	exit
end

#String holding file content
data = String.new

#Number of nodes and edges
q_nodes = 0
q_links = 0

#A data structure that represents each node
Neighbor = Struct.new(:name, :distance)
Node = Struct.new(:name, :neighbors)
nodes = Hash.new

fin = File.open(ARGV[0], 'r')

first_line = fin.gets
if (first_line =~ /(\d)\s(\d)/) then
	q_nodes = /(\d)\s(\d)/.match(first_line)[1]
	q_links = /(\d)\s(\d)/.match(first_line)[2]
else
	puts "Error: First line must indicate number of nodes and links!"
	exit
end

second_line = fin.gets
first_node = /(\w)/.match(second_line)[1]
if (second_line =~ /(\w)+/) then
	second_line.scan(/(\w)+/).each do |match|
		nodes[match[0]] = Node.new
		nodes[match[0]][:name] = match[0]
		nodes[match[0]][:neighbors] = Array.new
	end
else
	puts "Error: Second line must indicate at least 1 node name!"
	exit
end


re = /(\w) (\w) (\d+)/
fin.each_line do |line|
	src =  /(\w) \w \d+/.match(line)[1]
	dest = /\w (\w) \d+/.match(line)[1]
	dist = /\w \w (\d+)/.match(line)[1]
	n1 = Neighbor.new(dest, dist)
	n2 = Neighbor.new(src, dist)
	nodes[src][:neighbors].push(n1)
	nodes[dest][:neighbors].push(n2)
end
fin.close

#At this point the nodes hashtable is setup and ready to go
puts "Results from Dijkstra's Algorithm: "
dnw = Dijkstra.new(nodes, STDOUT)
dnw.find_shortest_path(first_node)

print("\n")

puts "Results from Bellman-Ford Algorithm: "
bfnw = Bellman_Ford.new(nodes, STDOUT)
bfnw.run

=begin

Bellman Ford Input Table:
  X Y Z
X 0 2 7
Y 2 0 1
Z 7 1 0

Complete Table:
  X Y Z
X 0 2 3
Y 2 0 1
Z 3 1 0

=end













