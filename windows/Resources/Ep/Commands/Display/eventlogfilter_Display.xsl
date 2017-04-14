<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>
 
 <xsl:template match="Events">  
  <xsl:apply-templates select="Event" />  
  	<xsl:variable name="parsed" select="@recordsParsed" />	
 	<xsl:variable name="total" select="count(Event)" />
 	<xsl:text>Records found:  </xsl:text>
 	<xsl:value-of select="$total" />
 	<xsl:call-template name="PrintReturn" />
 	<xsl:text>Records parsed: </xsl:text>
 	<xsl:value-of select="$parsed" />
 	<xsl:call-template name="PrintReturn" />
 </xsl:template>

 <!-- Event template -->
<xsl:template match="Event">
	<xsl:text>----------------------------------------------------------</xsl:text>
  	<xsl:call-template name="PrintReturn" />
	<!-- record number -->
	<xsl:text>    Record # : </xsl:text>
	<xsl:value-of select="@recordNumber" />
	<xsl:call-template name="PrintReturn" />
	<!-- EventType -->
 	<xsl:text>    Type     : </xsl:text>
 	<xsl:value-of select="@eventType" />
 	<xsl:call-template name="PrintReturn" />
 	<!-- Category -->
 	<xsl:text>    Category : </xsl:text>
 	<xsl:value-of select="@category" />
 	<xsl:call-template name="PrintReturn" />
 	<!-- Date/Time -->
 	<xsl:call-template name="printEvtDate"> 
 	<xsl:with-param name="i" select="WriteTime" /> 
 	</xsl:call-template> 
 	<!-- EventID -->
 	<xsl:text>    EventID  : </xsl:text>
 	<xsl:value-of select="@code" />
 	<xsl:call-template name="PrintReturn" />   
 	<!-- Source -->
 	<xsl:text>    Source   : </xsl:text>
 	<xsl:value-of select="@source" />
 	<xsl:call-template name="PrintReturn" />
 	<!-- user -->
 	<xsl:text>    User     : </xsl:text>
 	<xsl:value-of select="@user" /> 
 	<xsl:call-template name="PrintReturn" />
 	<!-- SID -->
  	<xsl:text>    SID      : </xsl:text>
 	<xsl:value-of select="@sid" /> 
 	<xsl:call-template name="PrintReturn" />	
 	<!-- computer -->
 	<xsl:text>    Computer : </xsl:text>
 	<xsl:value-of select="@computer" />
 	<xsl:call-template name="PrintReturn" />
 	<xsl:if test="../@brief = '0'">
 	 	<xsl:text>    Strings  :</xsl:text>
 	 	<xsl:call-template name="PrintReturn" />
		<xsl:apply-templates select="String" />
 	</xsl:if>
 	<xsl:call-template name="PrintReturn" />  	
</xsl:template>
<!-- end Event Template -->






  
 <!-- Strings Template -->
 <xsl:template match="String">
  <xsl:text>&#09;     </xsl:text>
  <xsl:value-of select="." />
  <xsl:call-template name="PrintReturn" />
 </xsl:template>






 
 <!-- Date/Time Template -->
 <xsl:template name="printEvtDate">
 <xsl:param name="i" />
 <xsl:variable name="year"   select="substring($i, 1,4)"    />
 <xsl:variable name="month"  select="substring($i, 6,2)"    /> 
 <xsl:variable name="day"    select="substring($i, 9,2)"    />
 <xsl:variable name="hour"   select="substring($i, 12, 2)"   />
 <xsl:variable name="minute" select="substring($i, 15, 2)"  />
 <xsl:variable name="second" select="substring($i, 18, 2)"  /> 
 <xsl:text>    Date     : </xsl:text>
 <xsl:value-of select="$month" /> 
 <xsl:text>/</xsl:text>
 <xsl:value-of select="$day" /> 
 <xsl:text>/</xsl:text>
 <xsl:value-of select="$year" />
 <xsl:call-template name="PrintReturn" />
 <xsl:text>    Time     : </xsl:text>
 <xsl:value-of select="$hour" /> 
 <xsl:text>:</xsl:text>
 <xsl:value-of select="$minute" /> 
 <xsl:text>:</xsl:text>
 <xsl:value-of select="$second" />
 <xsl:call-template name="PrintReturn" /> 
 </xsl:template>
 
 </xsl:transform>
