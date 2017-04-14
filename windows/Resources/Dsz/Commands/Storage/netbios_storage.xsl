<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="NetBios"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="NetBios">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">NetBios</xsl:attribute>			
			<xsl:apply-templates select="NCB"/>			
			<xsl:apply-templates select="Adapter"/>						
		</xsl:element>
	</xsl:template>	
	
	<xsl:template match="NCB">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">NCB</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">callName</xsl:attribute>
				<xsl:value-of select="CallName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">ncbName</xsl:attribute>
				<xsl:value-of select="NCBName"/>
			</xsl:element>				
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ncb_cmd_cplt</xsl:attribute>
				<xsl:value-of select="@ncb_cmd_cplt"/>
			</xsl:element>	
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ncb_command</xsl:attribute>
				<xsl:value-of select="@ncb_command"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ncb_lana_num</xsl:attribute>
				<xsl:value-of select="@ncb_lana_num"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ncb_lsn</xsl:attribute>
				<xsl:value-of select="@ncb_lsn"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ncb_num</xsl:attribute>
				<xsl:value-of select="@ncb_num"/>
			</xsl:element>	
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ncb_retcode</xsl:attribute>
				<xsl:value-of select="@ncb_retcode"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ncb_rto</xsl:attribute>
				<xsl:value-of select="@ncb_rto"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ncb_sto</xsl:attribute>
				<xsl:value-of select="@ncb_sto"/>
			</xsl:element>																											
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Adapter">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Adapter</xsl:attribute>					
			<xsl:apply-templates select="Names"/>						
			<xsl:element name="StringValue">
				<xsl:attribute name="name">adapter_addr</xsl:attribute>
				<xsl:value-of select="@adapter_addr"/>
			</xsl:element>				
			<xsl:element name="StringValue">
				<xsl:attribute name="name">adapter_type</xsl:attribute>
				<xsl:value-of select="@adapter_type"/>
			</xsl:element>					
			<xsl:element name="IntValue">
				<xsl:attribute name="name">duration</xsl:attribute>
				<xsl:value-of select="@duration"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">frmr_recv</xsl:attribute>
				<xsl:value-of select="@frame_recv"/>
			</xsl:element>				
			<xsl:element name="IntValue">
				<xsl:attribute name="name">frmr_xmit</xsl:attribute>
				<xsl:value-of select="@frame_xmit"/>
			</xsl:element>	
			<xsl:element name="IntValue">
				<xsl:attribute name="name">free_ncbs</xsl:attribute>
				<xsl:value-of select="@free_ncbs"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">iframe_recv_err</xsl:attribute>
				<xsl:value-of select="@iframe_recv_err"/>
			</xsl:element>	
			<xsl:element name="IntValue">
				<xsl:attribute name="name">iframe_xmit_err</xsl:attribute>
				<xsl:value-of select="@iframe_recv_err"/>
			</xsl:element>												
			<xsl:element name="IntValue">
				<xsl:attribute name="name">max_cfg_ncbs</xsl:attribute>
				<xsl:value-of select="@max_cfg_ncbs"/>
			</xsl:element>	
			<xsl:element name="IntValue">
				<xsl:attribute name="name">max_cfg_sess</xsl:attribute>
				<xsl:value-of select="@max_cfg_sess"/>
			</xsl:element>	
			<xsl:element name="IntValue">
				<xsl:attribute name="name">max_dgram_size</xsl:attribute>
				<xsl:value-of select="@max_dgram_size"/>
			</xsl:element>					
			<xsl:element name="IntValue">
				<xsl:attribute name="name">max_ncbs</xsl:attribute>
				<xsl:value-of select="@max_ncbs"/>
			</xsl:element>					
			<xsl:element name="IntValue">
				<xsl:attribute name="name">max_sess</xsl:attribute>
				<xsl:value-of select="@max_sess"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">max_sess_pkt_size</xsl:attribute>
				<xsl:value-of select="@max_sess_pkt_size"/>
			</xsl:element>				
			<xsl:element name="IntValue">
				<xsl:attribute name="name">name_count</xsl:attribute>
				<xsl:value-of select="@name_count"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">pending_sess</xsl:attribute>
				<xsl:value-of select="@pending_sess"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">recv_buff_unavail</xsl:attribute>
				<xsl:value-of select="@recv_buff_unavail"/>
			</xsl:element>			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">recv_success</xsl:attribute>
				<xsl:value-of select="@recv_success"/>
			</xsl:element>							
			<xsl:element name="StringValue">
				<xsl:attribute name="name">release</xsl:attribute>
				<xsl:value-of select="@release"/>
			</xsl:element>							
			<xsl:element name="IntValue">
				<xsl:attribute name="name">t1_timeouts</xsl:attribute>
				<xsl:value-of select="@t1_timeouts"/>
			</xsl:element>					
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ti_timeouts</xsl:attribute>
				<xsl:value-of select="@ti_timeouts"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">xmit_aborts</xsl:attribute>
				<xsl:value-of select="@xmit_aborts"/>
			</xsl:element>	
			<xsl:element name="IntValue">
				<xsl:attribute name="name">xmit_buff_unavail</xsl:attribute>
				<xsl:value-of select="@xmit_buf_unavail"/>
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">xmit_success</xsl:attribute>
				<xsl:value-of select="@xmit_success"/>
			</xsl:element>																																																																										
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Names">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Names</xsl:attribute>			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="Type"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">netName</xsl:attribute>
				<xsl:value-of select="NetName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="Name"/>
			</xsl:element>						
		</xsl:element>
	</xsl:template>
	
</xsl:transform>