require 'spec_helper'

describe LTSV do

  describe :parse do
    context 'String argument' do
      it 'can parse labeled tab separated values into hash' do
        line = "label1:value1\tlabel2:value2"
        LTSV.parse(line).should == {:label1 => 'value1', :label2 => 'value2'}
      end

      it 'can parse the value that contains escape sequences' do

        LTSV.parse("label1:value1\tlabel2:value\\nvalue").should ==
          {:label1 => 'value1', :label2 => "value\nvalue"}

        LTSV.parse("label1:value1\tlabel2:value\\rvalue").should ==
          {:label1 => 'value1', :label2 => "value\rvalue"}

        LTSV.parse("label1:value1\tlabel2:value\\tvalue").should ==
          {:label1 => 'value1', :label2 => "value\tvalue"}

        LTSV.parse("label1:value1\tlabel2:value\\\\value").should ==
          {:label1 => 'value1', :label2 => "value\\value"}
      end

      it 'parses the value as-is when the backslash with a following ordinal character' do

        LTSV.parse("label1:value1\tlabel2:value\\avalue").should ==
          {:label1 => 'value1', :label2 => "value\\avalue"}
      end

      it 'parses the empty value field as nil' do
        LTSV.parse("label1:\tlabel2:value2").should ==
          {:label1 => nil, :label2 => 'value2'}
      end
    end

    context 'IO argment' do
      it 'can parse labeled tab separated values into file' do
        LTSV.parse(File.open("#{File.dirname(__FILE__)}/test.ltsv")).should ==
          [{:label1 => 'value1', :label2 => 'value\\nvalue'},
           {:label3 => 'value3', :label4 => 'value\\rvalue'},
           {:label5 => 'value5', :label6 => 'value\\tvalue'},
           {:label7 => 'value7', :label8 => 'value\\\\value'}] 
      end
    end
  end

  describe :load do
  end

  describe :dump do

    specify 'dump into the format "label1:value1\tlabel2:value2"' do
      LTSV.dump({:label1 => "value1", :label2 => "value2"}).should ==
        "label1:value1\tlabel2:value2"
    end

    specify 'CRs, LFs, TABs, and backslashes in the value should be escaped' do
      LTSV.dump({:label1 => "value\rvalue"}).should == "label1:value\\rvalue"
      LTSV.dump({:label1 => "value\nvalue"}).should == "label1:value\\nvalue"
      LTSV.dump({:label1 => "value\tvalue"}).should == "label1:value\\tvalue"
      LTSV.dump({:label1 => "value\\value"}).should == "label1:value\\value"
    end

    specify ':s in the value should not be escaped' do
      LTSV.dump({:label1 => "value:value"}).should == "label1:value:value"
    end

    specify 'should not fail when object to dump responds to :to_hash' do
      target = Object.new
      target.instance_eval do
        def to_hash
          {:label => 'value'}
        end
      end
      LTSV.dump(target).should == "label:value"
    end

    specify 'fails when object to dump does not respond to :to_hash' do
      lambda{LTSV.dump(Object.new)}.should raise_exception(ArgumentError)
    end
  end
end
