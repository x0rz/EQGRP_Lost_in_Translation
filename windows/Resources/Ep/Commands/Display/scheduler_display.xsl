<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="NetJob">
  <xsl:text>          -----------------------------------------------------------------</xsl:text>
  <xsl:call-template name="PrintReturn" />

  <xsl:text>Name : </xsl:text>
  <xsl:value-of select="JobName" />
  <xsl:call-template name="PrintReturn" />

  <xsl:text>Date : </xsl:text>
  <xsl:call-template name="printTimeMDYHMS">
   <xsl:with-param name="i" select="NextRun/." />
  </xsl:call-template>
  <xsl:call-template name="PrintReturn" />

  <xsl:text>Account : </xsl:text>
  <xsl:value-of select="Account" />
  <xsl:call-template name="PrintReturn" />

  <xsl:text>Application : </xsl:text>
  <xsl:value-of select="Application" />
  <xsl:call-template name="PrintReturn" />

  <xsl:text>Parameters : </xsl:text>
  <xsl:value-of select="Parameters" />
  <xsl:call-template name="PrintReturn" />

  <xsl:for-each select="Triggers/Trigger">
   <xsl:text>Triggers : </xsl:text>
   <xsl:value-of select="." />
   <xsl:call-template name="PrintReturn" />
  </xsl:for-each>

 </xsl:template>


 <xsl:template match="AtHeader">
  <xsl:text>Entries Read:      </xsl:text>
  <xsl:value-of select="@read"/>
  <xsl:call-template name="PrintReturn" />
  <xsl:text>Entries Available: </xsl:text>
  <xsl:value-of select="@total"/>
  <xsl:call-template name="PrintReturn" />
  <xsl:call-template name="PrintReturn" />
  <xsl:text>Status Flags:</xsl:text>
  <xsl:call-template name="PrintReturn" />
  <xsl:text>        E -> ERROR,       Last attempted execution failed</xsl:text>
  <xsl:call-template name="PrintReturn" />
  <xsl:text>        P -> PERIODIC,    Program re-runs according to day/time info</xsl:text>
  <xsl:call-template name="PrintReturn" />
  <xsl:text>        T -> TODAY,       Program scheduled to run today</xsl:text>
  <xsl:call-template name="PrintReturn" />
  <xsl:text>        I -> INTERACTIVE, Program runs interactively</xsl:text>
  <xsl:call-template name="PrintReturn" />
  <xsl:call-template name="PrintReturn" />

  <xsl:text>Status ID  Day                      Time     Command</xsl:text>
  <xsl:call-template name="PrintReturn" />
  <xsl:text>--------------------------------------------------------------------------</xsl:text>
  <xsl:call-template name="PrintReturn" />
 </xsl:template>

 <xsl:template match="AtJob">
  <xsl:choose>
   <xsl:when test="Flags/JobExecError">
    <xsl:text>E</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text> </xsl:text>
   </xsl:otherwise>
  </xsl:choose>

  <xsl:choose>
   <xsl:when test="Flags/JobRunPeriodically">
    <xsl:text>P</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text> </xsl:text>
   </xsl:otherwise>
  </xsl:choose>

  <xsl:choose>
   <xsl:when test="Flags/JobRunsToday">
    <xsl:text>T</xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text> </xsl:text>
   </xsl:otherwise>
  </xsl:choose>

  <xsl:choose>
   <xsl:when test="Flags/JobNonInteractive">
    <xsl:text> </xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text>I</xsl:text>
   </xsl:otherwise>
  </xsl:choose>

  <xsl:call-template name="Whitespace">
   <xsl:with-param name="i" select="5 - string-length(@id)" />
  </xsl:call-template> 
  <xsl:value-of select="@id" />
  <xsl:text> </xsl:text>
  <xsl:choose>
   <xsl:when test="Flags/JobRunPeriodically">
    <xsl:text> Each</xsl:text>
    <xsl:call-template name="Recurrance">
	<xsl:with-param name="month" select="Monthday/@days" />
	<xsl:with-param name="space" select="20" />
    </xsl:call-template>
   </xsl:when>
   <xsl:when test="Flags/JobRunsToday">
    <xsl:text> Today                   </xsl:text>
   </xsl:when>
   <xsl:otherwise>
    <xsl:text> Next </xsl:text>
    <xsl:choose>
	<xsl:when test="Weekday/@monday = 'true'">
	    <xsl:text>M </xsl:text>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:text>  </xsl:text>
	</xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
	<xsl:when test="Weekday/@tuesday = 'true'">
	    <xsl:text>Tu </xsl:text>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:text>   </xsl:text>
	</xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
	<xsl:when test="Weekday/@wednesday = 'true'">
	    <xsl:text>W </xsl:text>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:text>  </xsl:text>
	</xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
	<xsl:when test="Weekday/@thursday = 'true'">
	    <xsl:text>Th </xsl:text>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:text>   </xsl:text>
	</xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
	<xsl:when test="Weekday/@friday = 'true'">
	    <xsl:text>F </xsl:text>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:text>  </xsl:text>
	</xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
	<xsl:when test="Weekday/@saturday = 'true'">
	    <xsl:text>Sa </xsl:text>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:text>   </xsl:text>
	</xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
	<xsl:when test="Weekday/@sunday = 'true'">
	    <xsl:text>Su </xsl:text>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:text>   </xsl:text>
	</xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    </xsl:otherwise>
  </xsl:choose>

  <xsl:text> </xsl:text>
  <xsl:value-of select="Time" />

  <xsl:text> </xsl:text>
  <xsl:value-of select="CommandText" />

  <xsl:call-template name="PrintReturn" />
 </xsl:template>

 <xsl:template name="Recurrance">
  <xsl:param name="month" />
  <xsl:param name="space" select="10" />
  <xsl:choose>

   <xsl:when test="$space &lt; 1">
   </xsl:when>

   <xsl:when test="$space &lt; 5 and ($month)">
    <xsl:text>.</xsl:text>
    <xsl:call-template name="Recurrance">
     <xsl:with-param name="month" select="$month" />
     <xsl:with-param name="space" select="$space - 1" />
    </xsl:call-template>
   </xsl:when>

   <xsl:when test="$month">
    <xsl:text> </xsl:text>
    <xsl:value-of select="$month[position() = 1]" />

    <xsl:call-template name="Recurrance">
     <xsl:with-param name="month" select="$month[position() &gt; 1]" />
     <xsl:with-param name="space" select="$space - ( 1 + string-length( $month[position() = 1] ) )" />
    </xsl:call-template>
   </xsl:when>

   <xsl:otherwise>
    <xsl:call-template name="Whitespace">
     <xsl:with-param name="i" select="$space" />
    </xsl:call-template>
   </xsl:otherwise>

  </xsl:choose>
 </xsl:template>

 <xsl:template match="NewJob">
  <xsl:text>New job added with id </xsl:text>
  <xsl:value-of select="@id" />
  <xsl:call-template name="PrintReturn" />
 </xsl:template>

 <xsl:template match="Deleted">
  <xsl:text>Job deleted</xsl:text>
  <xsl:call-template name="PrintReturn" />
 </xsl:template>

</xsl:transform>