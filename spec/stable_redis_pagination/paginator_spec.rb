require 'spec_helper'

describe StableRedisPagination::Paginator do
  before :all do
    Thing = Struct.new(:id, :score)
  end

  let(:things) { [] }

  before do
    things.each do |thing|
      StableRedisPagination.redis.zadd('things', thing.score, thing.id)
    end
  end

  let(:paginator)  { StableRedisPagination::Paginator.new('things') }

  describe "#can_paginate?" do
    let(:things) { [ Thing.new(1, 1) ] }
    specify { expect(paginator.can_paginate?).to eq(true) }
  end

  describe "#paginate" do

    context "with nothing in the index" do
      specify { expect(paginator.paginate).to eq([]) }
    end

    context "with entries in the index" do

      let(:things) do
        [
          Thing.new(5, 1),
          Thing.new(7, 2),
          Thing.new(1, 3),
          Thing.new(6, 4),
          Thing.new(3, 5),
          Thing.new(8, 6),
          Thing.new(4, 7),
          Thing.new(2, 8)
        ]
      end

      let(:ordered_thing_ids) { things.sort_by(&:score).map(&:id) }

      specify { expect(paginator.paginate).to eq(ordered_thing_ids) }

      context "with a specified count" do
        let(:count) { 4 }
        specify { expect(paginator.paginate(count: count)).to eq(ordered_thing_ids.first(count)) }
      end

      context "after a specified id" do
        specify { expect(paginator.paginate(after_id: 3)).to eq([8, 4, 2]) }

        context "that doesn't exist" do
          specify { expect(paginator.paginate(after_id: 99)).to eq(ordered_thing_ids) }
        end
      end

      context "in descending order" do
        specify { expect(paginator.paginate(order: 'desc')).to eq(ordered_thing_ids.reverse) }

        context "with a specified count" do
          let(:count) { 4 }
          specify { expect(paginator.paginate(order: 'desc', count: count)).to eq(ordered_thing_ids.reverse.first(count)) }
        end

        context "after a specified id" do
          specify { expect(paginator.paginate(order: 'desc', after_id: 6)).to eq([1, 7, 5]) }
        end
      end
    end
  end
end
