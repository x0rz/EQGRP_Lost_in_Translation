<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Events"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Events"> 
   <xsl:apply-templates select="Event" />
  </xsl:template>


  <xsl:template match="Event">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">record_number</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@recordNumber" /></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">event_type</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@eventType" /></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">category</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@category" /></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">event_id</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@code" /></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">time_stamp</xsl:attribute>
      <xsl:attribute name="value">
       <xsl:call-template name="printTimeMDYHMS">
        <xsl:with-param name="i" select="WriteTime" />
       </xsl:call-template>
      </xsl:attribute>
    </xsl:element>    

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">source</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@source" /></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">user</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@user" /></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">computer</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@computer" /></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">eventIdfull</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@eventId" /></xsl:attribute>
    </xsl:element>
           
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">sid</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@sid" /></xsl:attribute>
    </xsl:element>        
    
   <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">numberParsed</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@recordsParsed" /></xsl:attribute>
    </xsl:element>       
    
    <xsl:apply-templates select="String" />   
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
 <xsl:text>    Time     : </xsl:text>
 <xsl:value-of select="$hour" /> 
 <xsl:text>:</xsl:text>
 <xsl:value-of select="$minute" /> 
 <xsl:text>:</xsl:text>
 <xsl:value-of select="$second" />
 </xsl:template> 
  
  
 

  <xsl:template match="String">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">string_rec_num</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="../@recordNumber" /></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">strings</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="." /></xsl:attribute>
    </xsl:element>
  </xsl:template> 
 
</xsl:transform>