#
#  Copyright (c) 1999 by the University of Southern California
#  All rights reserved.
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License,
#  version 2, as published by the Free Software Foundation.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with this program; if not, write to the Free Software Foundation, Inc.,
#  59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
#
#  The copyright of this module includes the following
#  linking-with-specific-other-licenses addition:
#
#  In addition, as a special exception, the copyright holders of
#  this module give you permission to combine (via static or
#  dynamic linking) this module with free software programs or
#  libraries that are released under the GNU LGPL and with code
#  included in the standard release of ns-2 under the Apache 2.0
#  license or under otherwise-compatible licenses with advertising
#  requirements (or modified versions of such code, with unchanged
#  license).  You may copy and distribute such a system following the
#  terms of the GNU GPL for this module and the licenses of the
#  other code concerned, provided that you include the source code of
#  that other code when and as the GNU GPL requires distribution of
#  source code.
#
#  Note that people who make modified versions of this module
#  are not obligated to grant this special exception for their
#  modified versions; it is their choice whether to do so.  The GNU
#  General Public License gives permission to release a modified
#  version without this exception; this exception also makes it
#  possible to release a modified version which carries forward this
#  exception.

# Traffic source generator from CMU's mobile code.
#
# $Header: /cvsroot/nsnam/ns-2/indep-utils/cmu-scen-gen/cbrgen.tcl,v 1.4 2005/09/16 03:05:39 tomh Exp $

# ======================================================================
# Default Script Options
# ======================================================================
set opt(nn)		0		;# Number of Nodes
set opt(seed)		0.0
set opt(mc)		0
set opt(pktsize)	1000

set opt(rate)		0
set opt(interval)	0.0		;# inverse of rate
set opt(type)           ""

# ======================================================================

proc usage {} {
    global argv0

    puts "\nusage: $argv0 \[-type cbr|tcp|fulltcp\] \[-nn nodes\] \[-seed seed\] \[-mc connections\] \[-rate rate\]\n"
}

proc getopt {argc argv} {
	global opt
	lappend optlist nn seed mc rate type

	for {set i 0} {$i < $argc} {incr i} {
		set arg [lindex $argv $i]
		if {[string range $arg 0 0] != "-"} continue

		set name [string range $arg 1 end]
		set opt($name) [lindex $argv [expr $i+1]]
	}
}

proc create-cbr-connection { src dst } {
	global rng cbr_cnt opt

	set tempo [$rng uniform 0.0 0.1]

	puts "#\n# $src conectando a $dst no tempo $tempo\n#"

	puts "set udp_($cbr_cnt) \[new Agent/UDP\]"
	puts "\$ns_ attach-agent \$node_($src) \$udp_($cbr_cnt)"
	#puts "\$udp_($cbr_cnt) set fid_ $cbr_cnt"
	puts "set dest($cbr_cnt) \[new Agent/LossMonitor\]"
	puts "\$ns_ attach-agent \$node_($dst) \$dest($cbr_cnt)"
	puts "set cbr_($cbr_cnt) \[new Application/Traffic/CBR\]"
	puts "\$cbr_($cbr_cnt) set packetSize_ $opt(pktsize)"
	puts "\$cbr_($cbr_cnt) set rate_ $opt(rate)kb"
	#puts "\$cbr_($cbr_cnt) set interval_ $opt(interval)"
	#puts "\$cbr_($cbr_cnt) set random_ 1"
	puts "\$cbr_($cbr_cnt) attach-agent \$udp_($cbr_cnt)"
	puts "\$ns_ connect \$udp_($cbr_cnt) \$dest($cbr_cnt)"
	puts "\$ns_ at $tempo \"\$cbr_($cbr_cnt) start\""

	incr cbr_cnt
}

proc create-tcp-connection { src dst } {
	global rng cbr_cnt opt

	#set selfish [$rng integer $opt(nn)]
	set tempo [$rng uniform 0.0 1.0]

	puts "#\n# $src connecting to $dst at time $tempo \n#"
	puts "set tcp_($cbr_cnt) \[new Agent/TCP/Reno\]"
        puts "\$tcp_($cbr_cnt) set window_ 20"
	puts "\$tcp_($cbr_cnt) set packetSize_ $opt(pktsize)"
	puts "\$tcp_($cbr_cnt) set fid_ $cbr_cnt"
	puts "\$tcp_($cbr_cnt) set class_ 1"
	puts "set sink_($cbr_cnt) \[new Agent/TCPSink\]"
        puts "\$ns_ attach-agent \$node_($src) \$tcp_($cbr_cnt)"
        puts "\$ns_ attach-agent \$node_($dst) \$sink_($cbr_cnt)"
        puts "\$ns_ connect \$tcp_($cbr_cnt) \$sink_($cbr_cnt)"
        puts "set ftp_($cbr_cnt) \[new Application/FTP\]"
        puts "\$ftp_($cbr_cnt) attach-agent \$tcp_($cbr_cnt)"
	#puts "#Inserido Por Dioxfile agente monitor: cria um \[Agente/LossMonitor\]"
        #puts "set dest($cbr_cnt) \[new Agent/LossMonitor\]"
        #puts "\$ns_ attach-agent \$node_($dst) \$dest($cbr_cnt)"
        puts "\$ns_ at $tempo \"\$ftp_($cbr_cnt) start\""
         incr cbr_cnt
}

##Inserido por Dioxfile cria��o de conex�o com FullTcp
proc create-fulltcp-connection { src dst } {
        global rng cbr_cnt opt

        #set selfish [$rng integer $opt(nn)]
	set tempo [$rng uniform 0.0 100.0]
        #set stime [$rng uniform 0.0 180.0]
        puts "\#\n\# $src connecting to $dst at time $tempo\n\#"
        puts "\#Agente de transporte originador de tráfego"
        puts "set ftcp_($cbr_cnt) \[new Agent/TCP/FullTcp\]"
        puts "\$ftcp_($cbr_cnt) set class_ 1"
        puts "\$ftcp_($cbr_cnt) set window_ 32"
        puts "\$ftcp_($cbr_cnt) set fid_ $cbr_cnt"
        puts "\$ftcp_($cbr_cnt) set packetSize_ $opt(pktsize)"
        puts "#Agente de transporte sorvedouro de tráfego"
        puts "set sink_($cbr_cnt) \[new Agent/TCP/FullTcp\]"
        #puts "\$sink_($cbr_cnt) set class_ $cbr_cnt"
        #puts "\$sink_($cbr_cnt) set window_ 32"
        #puts "\$sink_($cbr_cnt) set fid_ $cbr_cnt"
        #puts "\$sink_($cbr_cnt) set packetSize_ $opt(pktsize)"
        puts "#Ligando os nodos aos agentes"
        puts "\$ns_ attach-agent \$node_($src)  \$ftcp_($cbr_cnt)"
        puts "\$ns_ attach-agent \$node_($dst)  \$sink_($cbr_cnt)"
        puts "#Conectando o Agente de transporte originador de tráfego ao agente sorvedouro"
        puts "\$ns_ connect \$ftcp_($cbr_cnt) \$sink_($cbr_cnt)"
        puts "\$sink_($cbr_cnt) listen"
        puts "#Criando uma Aplição para agente TCP"
        puts "set app_($cbr_cnt) \[new Application/TcpApp \$ftcp_($cbr_cnt)\]"
        puts "set appSink_($cbr_cnt) \[new Application/TcpApp \$sink_($cbr_cnt)\]"
        puts "#Conectando a Aplicação de origem a de destino"
        puts "\$app_($cbr_cnt) connect \$appSink_($cbr_cnt)"
        #puts "#Inserido Por Dioxfile agente monitor: cria um \[Agente\/LossMonitor\]"
        #puts "#Criando um Agente Monitor: Para pegar estatisticas da conexão"
        #puts "set dest($cbr_cnt) \[new Agent/LossMonitor\]"
        #puts "#Ligando o nodo sorvedouro ao monitor"
        #puts "\$ns_ attach-agent \$node_($dst) \$dest($cbr_cnt)"
        puts "#Iniciando o escalonador de eventos"
        puts "\$ns_ at $tempo  \"\$app_($cbr_cnt) send $opt(pktsize) \\\"\$appSink_($cbr_cnt) app-recev $opt(pktsize)\\\" start\""
	puts "Application/TcpApp instproc app-recv { size } {"
	puts "global ns_"
	puts "puts \"\[\$ns_ now\] \$appSink_($cbr_cnt) recebeu dados \$size de \$app_($cbr_cnt)\""
	puts "}"

   incr cbr_cnt

}

# ======================================================================

getopt $argc $argv

if { $opt(type) == "" } {
    usage
    exit
} elseif { $opt(type) == "cbr" } {
    if { $opt(nn) == 0 || $opt(seed) == 0.0 || $opt(mc) == 0 || $opt(rate) == 0 } {
	usage
	exit
    }

    set opt(interval) [expr 1 / $opt(rate)]
    if { $opt(interval) <= 0.0 } {
	puts "\ninvalid sending rate $opt(rate)\n"
	exit
    }
}

puts "#\n# nodes: $opt(nn), max conn: $opt(mc), send rate: $opt(interval), seed: $opt(seed)\n#"

set rng [new RNG]
$rng seed $opt(seed)

set u [new RandomVariable/Uniform]
$u set min_ 0
$u set max_ 100
$u use-rng $rng

set cbr_cnt 0
set src_cnt 0

for {set i 0} {$i < $opt(nn) } {incr i} {

	set x [$u value]

	if {$x < 50} {continue;}

	incr src_cnt

	set dst [expr ($i+1) % [expr $opt(nn) + 1] ]
	#if { $dst == 0 } {
	    #set dst [expr $dst + 1]
	    #}

	if { $opt(type) == "cbr" } {
		create-cbr-connection $i $dst
	} elseif { $opt(type) == "tcp"} {
                  create-tcp-connection $i $dst
	} else {
               create-fulltcp-connection $i $dst
        }

	if { $cbr_cnt == $opt(mc) } {
		break
	}

	if {$x < 75} {continue;}

	set dst [expr ($i+2) % [expr $opt(nn) + 1] ]
	#if { $dst == 0 } {
		#set dst [expr $dst + 1]
	#}

	if { $opt(type) == "cbr" } {
		create-cbr-connection $i $dst
	} elseif { $opt(type) == "tcp" } {
		create-tcp-connection $i $dst
	} else {
               create-fulltcp-connection $i $dst
        }

	if { $cbr_cnt == $opt(mc) } {
		break
	}
}

puts "#\n#Total sources/connections: $src_cnt/$cbr_cnt\n#"


