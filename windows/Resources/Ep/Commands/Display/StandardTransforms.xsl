<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="text"/>

  <xsl:template match="/Data">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="Instance" />
  <xsl:template match="Command" />

  <xsl:template match="*">
	<xsl:call-template name="PrintXml"/>
  </xsl:template>

  <xsl:template match="Autoload">Autoloading plugin <xsl:value-of select="@plugin"/> (<xsl:value-of select="@type"/>)<xsl:text>&#x0D;&#x0A;</xsl:text></xsl:template>

  <xsl:template match="Error">
*
* Error: <xsl:copy-of select="."/>
*
</xsl:template>
	
  <xsl:template match="Error[@type='plugin']">
	<xsl:copy-of select="."/>
	<xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:template>

  <xsl:template match="Error[@type='system']">
	<xsl:copy-of select="."/>
	<xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:template>

  <xsl:template match="Exception[@location='lp']">
    <xsl:choose>
	<xsl:when test="Exception[@request]">

*************************************************************************
*
* Local command (request <xsl:value-of select="@request"/>) has exited by an exception
* 
* Command: <xsl:value-of select="."/>
*
* Please notify the plugin developer of this problem.
*
*************************************************************************

	</xsl:when>
	<xsl:otherwise>


*************************************************************************
*
* LOCAL channel ID <xsl:value-of select="@id"/> has exited by an exception
* 
* Please notify the plugin developer of this problem.
*
*************************************************************************

	</xsl:otherwise>
    </xsl:choose>
</xsl:template>

  <xsl:template match="Exception[@location='implant']">

*************************************************************************
*
* REMOTE channel ID <xsl:value-of select="@id"/> has exited by an exception
* 
* Please notify the plugin developer of this problem.
*
*************************************************************************

</xsl:template>

  <xsl:template match="Failure">
        *** Command indicated failure ***
</xsl:template>

  <xsl:template match="Info">
	<xsl:value-of select="."/>
	<xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:template>

  <xsl:template match="IntermediateSuccess">
	<xsl:text>Command </xsl:text>
	<xsl:value-of select="@request"/>
	<xsl:text> indicated success and will continue to run in the background&#x0D;&#x0A;</xsl:text>
  </xsl:template>

  <!-- by default, ignore these elements -->
  <xsl:template match="Alias"/>
  <xsl:template match="Command"/>
  <xsl:template match="Instance"/>
  <xsl:template match="Success"/>
  <xsl:template match="CtrlC"/>

  <!-- FUNCTIONS -->

  <!-- 
	Whitespace(int i)
	    Prints i whitespaces.
  -->
  <xsl:template name="Whitespace">
     <xsl:param name="i"/>
     <xsl:if test="number($i) > 0">
        <xsl:text> </xsl:text>
        <xsl:call-template name="Whitespace">
           <xsl:with-param name="i" select="number($i) - 1"/>
	</xsl:call-template> 
     </xsl:if>
  </xsl:template>

  <xsl:template name="CharFill">
     <xsl:param name="i"/>
     <xsl:param name="char" />
     <xsl:if test="number($i) > 0">
        <xsl:value-of select="$char" />
        <xsl:call-template name="CharFill">
           <xsl:with-param name="i"    select="number($i) - 1"/>
           <xsl:with-param name="char" select="$char" />
	</xsl:call-template> 
     </xsl:if>
  </xsl:template>
  <!--
	PrintXml()
	    Prints the current node as XML
  -->
  <xsl:template name="PrintXml">&lt;<xsl:copy-of select="name(.)"/> ...&gt;<xsl:copy-of select="."/>&lt;/<xsl:copy-of select="name(.)"/>&gt;<xsl:text>&#x0D;&#x0A;</xsl:text></xsl:template>

 <xsl:template name="printTimeMDYHMS">
  <xsl:param name="i" />
  <xsl:variable name="date"   select="substring-before($i, 'T')"                          />
  <xsl:variable name="time"   select="substring-after ($i, 'T')"                          />
  <xsl:variable name="year"   select="substring-before($date, '-')"                       />
  <xsl:variable name="month"  select="substring-before(substring-after($date, '-'), '-')" />
  <xsl:variable name="day"    select="substring-after (substring-after($date, '-'), '-')" />
  <xsl:variable name="hour"   select="substring-before($time, ':')"                       />
  <xsl:variable name="minute" select="substring-before(substring-after($time, ':'), ':')" />
  <xsl:variable name="second" select="substring-after (substring-after($time, ':'), ':')" />
  <xsl:value-of select="$month" />
  <xsl:text>/</xsl:text>
  <xsl:value-of select="$day" />
  <xsl:text>/</xsl:text>
  <xsl:value-of select="$year" />
  <xsl:text> </xsl:text>
  <xsl:value-of select="$hour" />
  <xsl:text>:</xsl:text>
  <xsl:value-of select="$minute" />
  <xsl:text>:</xsl:text>
  <xsl:value-of select="$second" />

 </xsl:template>

 <xsl:template name="printTimeHMS">
  <xsl:param name="i" />
  <xsl:variable name="time"   select="substring-after ($i, 'T')"                          />
  <xsl:variable name="hour"   select="substring-before($time, ':')"                       />
  <xsl:variable name="minute" select="substring-before(substring-after($time, ':'), ':')" />
  <xsl:variable name="second" select="substring-after (substring-after($time, ':'), ':')" />
  <xsl:value-of select="$hour" />
  <xsl:text>:</xsl:text>
  <xsl:value-of select="$minute" />
  <xsl:text>:</xsl:text>
  <xsl:value-of select="$second" />

 </xsl:template>

  <xsl:template name="PrintReturn">
	<xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:template>

</xsl:transform>